module Remarkable
  module DSL
    module Assertions

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

          include Remarkable::DSL::Matches unless ancestors.include?(Remarkable::DSL::Matches)

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
  after_initialize if self.respond_to?(:after_initialize)
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

    end
  end
end
