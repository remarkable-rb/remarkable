module Remarkable # :nodoc:
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

          if collection = options.delete(:collection)
            @matcher_arguments[:collection] = collection
            @matcher_arguments[:as]         = singularize!(@matcher_arguments[:loop].to_s, options.delete(:as))

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
        def assertions(*methods)
          @matcher_for_assertions += methods
        end
        alias :collection_assertions :assertions

        # In contrast to assertions, the methods given here are run just once.
        # In other words, it does not iterate through the collection given
        # in arguments.
        #
        def single_assertions(*methods)
          @matcher_assertions += methods
        end

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
        def optional(*names)
          options = names.extract_options!

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
              attr_reader :matcher_arguments, :matcher_assertions, :matcher_for_assertions
            end
          end

          base.instance_variable_set('@matcher_arguments',      @matcher_arguments      || {})
          base.instance_variable_set('@matcher_assertions',     @matcher_assertions     || [])
          base.instance_variable_set('@matcher_for_assertions', @matcher_for_assertions || [])
        end

    end

    # Gets the collection and loops it setting an instance variable with its
    # singular name. For example, if loop_argument is :good_values, we
    # will get @good_values and then set the instance variable @good_value.
    #
    # Then we call all methods declared in single_assertion. This method
    # receives the subject as argument and provides a before assert callback
    # that you might want to use it when you want to manipulate the subject
    # before the assertions start.
    #
    def matches?(subject)
      @subject = subject

      before_assert

      assert_matcher do
        self.class.matcher_assertions.inject(true) do |bool, method|
          bool && send_assertion_method(method)
        end
      end &&
      assert_matcher_for(instance_variable_get("@#{self.class.matcher_arguments[:collection]}") || []) do |value|
        instance_variable_set("@#{self.class.matcher_arguments[:as]}", value)

        self.class.matcher_for_assertions.inject(true) do |bool, method|
          bool && send_assertion_method(method)
        end
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

      # Overwrite to provide a callback before begin assertions.
      # You might want to use it when you want to manipulate the @subject
      # before the assertions start.
      #
      def before_assert
      end

      # Helper to call assertions.
      #
      def send_assertion_method(method)
        if method.is_a? Array
          send(*method)
        else
          send(method)
        end
      end

  end
end
