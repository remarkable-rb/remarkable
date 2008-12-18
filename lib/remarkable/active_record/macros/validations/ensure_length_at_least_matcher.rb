module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class EnsureLengthAtLeast < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, min_length, *options)
          @attribute  = attribute
          @min_length = min_length
          load_options(options)
        end

        def short_message(short_message)
          @options[:short_message] = short_message
          self
        end

        def matches?(subject)
          @subject = subject

          assert_matcher do
            at_least_min_length? && less_than_min_length?
          end
        end

        def description
          expectation
        end

        def failure_message
          "Expected to #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect to #{expectation}"
        end

        private

        def load_options(options)
          @options = {
            :short_message => remove_parenthesis(default_error_message(:too_short, :count => @min_length))
          }.merge(options.extract_options!)
        end

        def less_than_min_length?
          return true unless @min_length > 0

          min_value = "x" * (@min_length - 1)
          return true if assert_bad_value(@subject, @attribute, min_value, @options[:short_message])

          @missing = "allow #{@attribute} to be less than #{@min_length} chars long"
          return false          
        end

        def at_least_min_length?
          valid_value = "x" * (@min_length)
          return true if assert_good_value(@subject, @attribute, valid_value, @options[:short_message])
          @missing = "not allow #{@attribute} to be at least #{@min_length} chars long"
          false
        end

        def expectation
          "allow #{@attribute} to be at least #{@min_length} chars long"
        end
      end

      # Ensures that the length of the attribute is at least a certain length
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % min_length</tt>
      #
      # Example:
      #   it { should ensure_length_at_least(:name, 3) }
      #
      def ensure_length_at_least(attribute, min_length, *options)
        EnsureLengthAtLeast.new(attribute, min_length, *options)
      end
    end
  end
end
