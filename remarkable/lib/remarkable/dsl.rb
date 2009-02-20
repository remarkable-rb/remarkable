module Remarkable
  module DSL

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      protected

        # It sets the arguments your matcher receives on initialization.
        #
        #   arguments :name, :range
        #
        # Which is roughly the same as:
        #
        #   def initialize(name, range, options = {})
        #     @name    = name
        #     @range   = range
        #     @options = options
        #   end
        #
        # But most of the time your matchers iterates through a collection,
        # such as a collection of attributes in the case below:
        #
        #   @product.should validate_presence_of(:title, :name)
        #
        # validate_presence_of is a matcher declared as:
        #
        #   class ValidatePresenceOfMatcher < Remarkable::Base
        #     arguments :collection => :attributes
        #   end
        #
        # In this case, Remarkable provides an API that enables you to easily
        # assert each item of the collection. Let's check more examples:
        #
        #   should allow_values_for(:email, "jose@valim.com", "carlos@brando.com")
        #
        # Is declared as:
        #
        #   arguments :attribute, :collection => :good_values
        #
        # And this is the same as:
        #
        #   class AllowValuesForMatcher < Remarkable::Base
        #     def initialize(attribute, *good_values)
        #       @attribute = attribute
        #       @options = default_options.merge(good_values.extract_options!)
        #       @good_values = good_values
        #     end
        #   end
        #
        # Now, the collection is @good_values. In each assertion method we will
        # have a @good_value variable (in singular) instantiated with the value
        # to assert.
        #
        # If ActiveSupport is not loaded, we cannot singularize a string and
        # an error will be raised unless you give :as as option:
        #
        #   arguments :collection => :attributes, :as => :attribute
        #
        # Finally, if your matcher deals with blocks, you can also set them as
        # option:
        #
        #   arguments :name, :block => :builder
        #
        # It will be available under the instance variable @builder.
        #
        def arguments(*names)
          options = names.extract_options!
          args = names.dup

          @matcher_arguments[:names] = names

          if collection = options.delete(:collection)
            @matcher_arguments[:collection] = collection
            @matcher_arguments[:as]         = singularize!(@matcher_arguments[:collection].to_s, options.delete(:as))

            args          << "*#{collection}"
            get_options    = "#{collection}.extract_options!"
            set_collection = "@#{collection} = #{collection}"
          else
            args          << 'options={}'
            get_options    = 'options'
            set_collection = ''
          end

          if block = options.delete(:block)
            @matcher_arguments[:block] = block
            args  << "&#{block}"
            names << block
          end

          assignments = names.map do |name|
            "@#{name} = #{name}"
          end.join("\n  ")

          class_eval <<-END, __FILE__, __LINE__
def initialize(#{args.join(',')})
  #{assignments}
  @options = default_options.merge(#{get_options})
  #{set_collection}
  after_initialize
end
END
        end

        # Call it to declare your matcher assertions. Every method given will
        # iterate through the whole collection given in <tt>:arguments</tt>.
        #
        # For example, validate_presence_of can be written as:
        #
        #   class ValidatePresenceOfMatcher < Remarkable::Base
        #     arguments  :attributes
        #     assertions :allow_nil?
        #
        #     protected
        #       def allow_nil?
        #         # matcher logic
        #       end
        #   end
        #
        # Then we call it as:
        #
        #   should validate_presence_of(:email, :password)
        #
        # For each attribute given, it will call the method :allow_nil which
        # contains the matcher logic. As stated in <tt>arguments</tt>, those
        # attributes will be available under the instance variable @argument
        # and the matcher subject is available under the instance variable
        # @subject.
        #
        # If a block is given, it will create a method with the name given.
        # So we could write the same class as above just as:
        #
        #   class ValidatePresenceOfMatcher < Remarkable::Base
        #     arguments :attributes
        #
        #     assertion :allow_nil? do
        #       # matcher logic
        #     end
        #   end
        #
        # Those methods should return true if it pass or false if it fails. When
        # it fails, it will use I18n API to find the proper failure message:
        #
        #   missing:
        #     allow_nil?: allowed the value to be nil
        #     allow_blank?: allowed the value to be blank
        #
        # Or you can set the message in the instance variable @missing in the
        # assertion method if you don't want to rely on I18n API.
        #
        # As you might have noticed from samples, this method is also aliased
        # as <tt>assertion</tt>.
        #
        def assertions(*methods, &block)
          define_method methods.last, &block if block_given?
          @matcher_for_assertions += methods
        end
        alias :assertion :assertions

        # In contrast to <tt>assertions</tt>, the methods given here are called
        # just once. In other words, it does not iterate through the collection
        # given in arguments.
        #
        # It also accepts blocks and is aliased as single_assertion. Check
        # <tt>assertions</tt> for more info.
        #
        def single_assertions(*methods, &block)
          define_method methods.last, &block if block_given?
          @matcher_assertions += methods
        end
        alias :single_assertion :single_assertions

        # Creates optional handlers for matchers dynamically. The following
        # statement:
        #
        #   optional :range, :default => 0..10
        #
        # Will generate:
        #
        #   def range(value=0..10)
        #     @options ||= {}
        #     @options[:range] = value
        #     self
        #   end
        #
        # Options:
        #
        # * <tt>:default</tt> - The default value for this optional
        # * <tt>:alias</tt>  - An alias for this optional
        #
        # Examples:
        #
        #   optional :name, :title
        #   optional :range, :default => 0..10, :alias => :within
        #
        # Optionals will be included in description messages if you assign them
        # properly on your locale file. If you have a validate_uniqueness_of
        # matcher with the following on your locale file:
        #
        #   description: validate uniqueness of {{attributes}}
        #   optional:
        #     scope:
        #       given: scoped to {{inspect}}
        #     case_sensitive:
        #       positive: case sensitive
        #       negative: case insensitive
        #
        # When invoked like below will generate the following messages:
        #
        #   validate_uniqueness_of :project_id, :scope => :company_id
        #   #=> "validate uniqueness of project_id scoped to company_id"
        #
        #   validate_uniqueness_of :project_id, :scope => :company_id, :case_sensitive => true
        #   #=> "validate uniqueness of project_id scoped to company_id and case sensitive"
        #
        #   validate_uniqueness_of :project_id, :scope => :company_id, :case_sensitive => false
        #   #=> "validate uniqueness of project_id scoped to company_id and case insensitive"
        #
        # The options for each optional are:
        #
        #   * <tt>positive</tt> - When the key is given and it's not false or nil.
        #   * <tt>negative</tt> - When the key is given and it's false or nil.
        #   * <tt>given</tt> - When the key is given, doesn't matter the value.
        #   * <tt>not_given</tt> - When the key is not given.
        #
        def optional(*names)
          options = names.extract_options!
          @matcher_optionals += names

          names.each do |name|
            class_eval <<-END, __FILE__, __LINE__
def #{name}(value#{ options[:default] ? "=#{options[:default].inspect}" : "" })
  @options ||= {}
  @options[:#{name}] = value
  self
end
END
          end
          class_eval "alias_method(:#{options[:alias]}, :#{names.last})" if options[:alias]
        end

        # Class method that accepts a block which is called after initialization.
        #
        def after_initialize(&block)
          define_method :after_initialize, &block
        end

        # Class method that accepts a block which is called before assertion.
        #
        def before_assert(&block)
          define_method :before_assert, &block
        end

        # Class method that accepts a block or a Hash that will overwrite
        # instance method default_options.
        #
        def default_options(hash = {}, &block)
          if block_given?
            define_method :default_options, &block
          else
            class_eval "def default_options; #{hash.inspect}; end"
          end
        end

      private

        # Helper that deals with string singularization. If a default is not given
        # delegates to String#singularize if available or raise an error if not.
        #
        def singularize!(string, default=nil)
          return default if default

          if string.respond_to? :singularize
            string.singularize
          else
            raise ArgumentError, "String does not respond to singularize. Please give :as as option in arguments."
          end
        end

        # Make Remarkable::Base DSL inheritable.
        #
        def inherited(base)
          base.class_eval do
            class << self
              attr_reader :matcher_arguments, :matcher_optionals, :matcher_assertions, :matcher_for_assertions
            end
          end

          base.instance_variable_set('@matcher_arguments',      @matcher_arguments      || { :names => [] })
          base.instance_variable_set('@matcher_optionals',      @matcher_optionals      || [])
          base.instance_variable_set('@matcher_assertions',     @matcher_assertions     || [])
          base.instance_variable_set('@matcher_for_assertions', @matcher_for_assertions || [])
        end
    end

    # Overwrites description to support optionals. Check <tt>optional</tt> for
    # more information.
    #
    def description(options={})
      message = super(options)

      optionals = self.class.matcher_optionals.map do |optional|
        scope = matcher_i18n_scope + ".optional.#{optional}"

        if @options.key?(optional)
          i18n_key = @options[optional] ? :positive : :negative
          Remarkable.t i18n_key, :default => :given, :raise => true, :scope => scope, :inspect => @options[optional].inspect
        else
          Remarkable.t :not_given, :raise => true, :scope => scope
        end rescue nil
      end.compact

      if optionals.empty?
        message
      else
        message + " " + array_to_sentence(optionals)
      end
    end

    # For each instance under the collection declared in <tt>arguments</tt>,
    # this method will call each method declared in <tt>assertions</tt>.
    #
    # As an example, let's assume you have the following matcher:
    #
    #   arguments  :collection => :attributes
    #   assertions :allow_nil?, :allow_blank?
    #
    # For each attribute in @attributes, we will set the instance variable
    # @attribute and then call allow_nil? and allow_blank?. Assertions should
    # return true if it pass or false if it fails. When it fails, it will use
    # I18n API to find the proper failure message:
    #
    #   missing:
    #     allow_nil?: allowed the value to be nil
    #     allow_blank?: allowed the value to be blank
    #
    # Or you can set the message in the instance variable @missing in the
    # assertion method if you don't want to rely on I18n API.
    #
    # This method also call the methods declared in single_assertions. Which
    # work the same way as assertions, except it doesn't loop for each value in
    # the collection.
    #
    # It also provides a before_assert callback that you might want to use it
    # to manipulate the subject before the assertions start.
    #
    def matches?(subject)
      @subject = subject

      before_assert

      assert_matcher do
        send_methods_and_generate_message(self.class.matcher_assertions)
      end &&
      assert_matcher_for(instance_variable_get("@#{self.class.matcher_arguments[:collection]}") || []) do |value|
        instance_variable_set("@#{self.class.matcher_arguments[:as]}", value)
        send_methods_and_generate_message(self.class.matcher_for_assertions)
      end
    end

    protected

      # Overwrite to provide default options.
      #
      def default_options
        {}
      end

      # Overwrite to provide a callback called after initialization.
      #
      def after_initialize
      end

      # Overwrite to provide a callback before begin assertions. You might want
      # to use it to manipulate the @subject before assertions start.
      #
      def before_assert
      end

      # Overwrites default_i18n_options to provide collection interpolation.
      #
      def default_i18n_options
        options = super

        # Add collection to options
        if collection_name = self.class.matcher_arguments[:collection]
          collection_name = collection_name.to_sym
          collection = instance_variable_get("@#{collection_name}")
          options[collection_name] = array_to_sentence(collection) if collection

          object_name = self.class.matcher_arguments[:as].to_sym
          object = instance_variable_get("@#{object_name}")
          options[object_name] = object if object
        end

        # Add arguments to options
        self.class.matcher_arguments[:names].each do |name|
          options[name] = instance_variable_get("@#{name}").inspect
        end

        options
      end

      # Helper that send the methods given and create a missing message if any
      # returns false.
      #
      def send_methods_and_generate_message(methods)
        methods.each do |method|
          bool, hash = send(method)

          unless bool
            @missing ||= Remarkable.t "missing.#{method}", default_i18n_options.merge(hash || {})
            return false
          end
        end

        return true
      end
  end
end
