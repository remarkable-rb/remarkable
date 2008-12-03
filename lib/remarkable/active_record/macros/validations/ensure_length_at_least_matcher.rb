module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class EnsureLengthAtLeast < Remarkable::Matcher::Base
        include Remarkable::Private
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, min_length, opts = {})
          @options = {}
          @options[:short_message] = get_options!([opts], :short_message)
          @attribute  = attribute
          @min_length = min_length
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

        def model_class
          @subject
        end

        def short_message
          @options[:short_message] ||= /#{default_error_message(:too_short, :count => @min_length).gsub(/\s?\(.*\)$/, '')}/
        end

        def less_than_min_length?
          if @min_length > 0
            min_value = "x" * (@min_length - 1)
            return true if assert_bad_value(model_class, @attribute, min_value, short_message)
            @missing = "allow #{@attribute} to be less than #{@min_length} chars long"
            false
          else
            true
          end
        end

        def at_least_min_length?
          valid_value = "x" * (@min_length)
          return true if assert_good_value(model_class, @attribute, valid_value, short_message)
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
      def ensure_length_at_least(attribute, min_length, opts = {})
        EnsureLengthAtLeast.new(attribute, min_length, opts)
      end
    end
  end
end
