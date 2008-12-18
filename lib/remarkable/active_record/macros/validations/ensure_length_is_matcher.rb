module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class EnsureLengthIs < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, length, *options)
          @attribute = attribute
          @length    = length
          load_options(options)
        end

        def message(message)
          @options[:message] = message
          self
        end
        
        def matches?(subject)
          @subject = subject

          assert_matcher do
            less_than_length? &&
            greater_than_length? &&
            exactly_length?
          end
        end

        def description
          "ensure #{expectation}"
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end
        
        private
        
        def less_than_length?
          min_value = "x" * (@length - 1)
          return true if assert_bad_value(@subject, @attribute, min_value, @options[:message])

          @missing = "allow #{@attribute} to be less than #{@length} chars long"
          return false
        end
        
        def greater_than_length?
          max_value = "x" * (@length + 1)
          return true if assert_bad_value(@subject, @attribute, max_value, @options[:message])

          @missing = "allow #{@attribute} to be greater than #{@length} chars long"
          return false
        end
        
        def exactly_length?
          valid_value = "x" * (@length)
          return true if assert_good_value(@subject, @attribute, valid_value, @options[:message])

          @missing = "not allow #{@attribute} to be #{@length} chars long"
          return false
        end
        
        def load_options(options)
          @options = {
            :message => remove_parenthesis(default_error_message(:wrong_length, :count => @length))
          }.merge(options.extract_options!)
        end
        
        def expectation
          "that the length of the #{@attribute} is exactly #{@length} chars long"
        end
      end

      # Ensures that the length of the attribute is exactly a certain length
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.wrong_length') % length</tt>
      #
      # Example:
      #   it { should ensure_length_is(:ssn, 9) }
      #
      def ensure_length_is(attribute, length, *options)
        EnsureLengthIs.new(attribute, length, *options)
      end
    end
  end
end
