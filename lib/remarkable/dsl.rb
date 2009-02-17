module Remarkable # :nodoc:
  module Matcher # :nodoc:
    module DSL

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          class_inheritable_accessor :loop_argument, :instance_writer => false
          class_inheritable_reader   :matcher_for_assertions, :matcher_assertions

          # loop_argument is the value the we are going to loop with
          # assert_matcher_for.
          self.loop_argument = nil

          # matcher_for_assertions contains the methods that should be called
          # inside assert_matcher_for.
          assertions()

          # matcher_assertions contains the methods that should be called
          # inside assert_matcher.
          single_assertions()
        end
      end

      module ClassMethods

        protected

          def assertions(*methods)
            write_inheritable_array(:matcher_for_assertions, methods)
          end

          def single_assertions(*methods)
            write_inheritable_array(:matcher_assertions, methods)
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

          # It sets the arguments your matcher receives on initialization. The
          # last name given must be always plural and it will be the values
          # that the matcher loops with. For example:
          #
          #   @product.shuold validate_presence_of(:title, :name)
          #
          # validate_presence_of is a matcher declared as:
          #
          #   class ValidatePresenceOfMatcher < Remarkable::Matcher::Base
          #     arguments :attributes
          #   end
          #
          # And this is the same as:
          #
          #   class ValidatePresenceOfMatcher < Remarkable::Matcher::Base
          #     def initialize(*attributes)
          #       @options = default_options.merge(attributes.extract_options!)
          #       @attributes = attributes
          #     end
          #   end
          #
          # As you noticed, it will set instance variable with same name of the
          # given values in <tt>arguments</tt>. Also, for each attribute given
          # in @attributes the matcher will run all assertions declared with
          # <tt>assertions</tt>.
          #
          # So validate_presence_of can be written as:
          #
          #   class ValidatePresenceOfMatcher < Remarkable::Matcher::Base
          #     arguments  :attributes
          #     assertions :check_nil
          #
          #     protected
          #       def check_nil
          #         @subject.send("#{@attribute}=", nil)
          #         !@subject.save
          #       end
          #   end
          #
          # What it does is simple. For each attribute in @attributes, it will
          # set the @attribute variable (in singular) and then call :check_nil.
          #
          # In check_nil, we can also see an instance_variable called @subject
          # which is the object we called should on. Then we set the attribute
          # given to nil and tries to save the object.
          #
          # If check nil returns true, that means the value does not accept nil
          # and then it validate_presence_of is checked. If it return false for
          # any given attribute, it will not pass.
          #
          # Let's see more examples:
          #
          #   should allow_values_for(:email, "jose@valim.com", "carlos@brando.com")
          #
          # Is declared as:
          #
          #   arguments :attribute, :good_values
          #
          # And this is the same as:
          #
          #   class AllowValuesForMatcher < Remarkable::Matcher::Base
          #     def initialize(attribute, *good_values)
          #       @attribute = attribute
          #       @options = default_options.merge(good_values.extract_options!)
          #       @good_values = good_values
          #     end
          #   end
          #
          # Now, the variable we will loop is @good_values. In each assertion
          # method we will have a @good_value variable instantiated with the
          # value to assert. The instance variable @attribute is also available
          # and is always the same, since it's not the variable we are looping.
          #
          def arguments(*names)
            self.loop_argument = names.pop.to_s
            args               = (names + [ "*#{self.loop_argument}" ]).join(', ')

            assignments = names.map do |name|
              "@#{name} = #{name}"
            end.join("\n")

            class_eval <<-END, __FILE__, __LINE__
def initialize(#{args})
  #{assignments}
  @options = default_options.merge(#{self.loop_argument}.extract_options!)
  @#{self.loop_argument} = #{self.loop_argument}
  after_initialize
end
END
          end
      end

      def matches?(subject)
        @subject = subject

        before_assert

        # Gets the loop_argument and loops it setting the singular name of
        # loop argument. For example, if loop_argument is :good_values, we
        # will get @good_values and then set the instance variable @good_value.
        #
        # Then we go for each method declared in assertions and eval it.
        # Later we do the same for each method declared in single_assertion.
        #
        assert_matcher_for(instance_variable_get("@#{loop_argument}")) do |value|
          instance_variable_set("@#{loop_argument.singularize}", value)

          matcher_for_assertions.inject(true) do |bool, method|
            bool && send_assertion_method(method)
          end
        end &&
        assert_matcher do
          matcher_assertions.inject(true) do |bool, method|
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

        def send_assertion_method(method)
          if method.is_a? Array
            send(*method)
          else
            send(method)
          end
        end

        # Callback called after initialization.
        #
        def after_initialize
        end

        # Callback before begin assertions.
        #
        def before_assert
        end

    end
  end
end
