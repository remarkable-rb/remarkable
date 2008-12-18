module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class EnsureValueInRange < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, range, *options)
          @attribute = attribute
          @range     = range
          load_options(options)
        end
        
        def low_message(message)
          @options[:low_message] = message
          self
        end
        
        def high_message(message)
          @options[:high_message] = message
          self
        end

        def matches?(subject)
          @subject = subject

          assert_matcher do
            less_than_minimum? &&
            accepts_minimum? &&
            more_than_maximum? &&
            accepts_maximum?
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
        
        def expectation
          "that the #{@attribute} is in #{@range}"
        end
        
        def less_than_minimum?
          return true if assert_bad_value(@subject, @attribute, (@range.first - 1), @options[:low_message])

          @missing = "allow #{@attribute} to be less than #{@range.first}"
          return false
        end
        
        def accepts_minimum?
          return true if assert_good_value(@subject, @attribute, @range.first, @options[:low_message])

          @missing = "not allow #{@attribute} to be #{@range.first}"
          return false
        end
        
        def more_than_maximum?
          return true if assert_bad_value(@subject, @attribute, (@range.last + 1), @options[:high_message])
          
          @missing = "allow #{@attribute} to be more than #{@range.last}"
          return false
        end
        
        def accepts_maximum?
          return true if assert_good_value(@subject, @attribute, @range.last, @options[:high_message])
          
          @missing = "not allow #{@attribute} to be #{@range.last}"
          return false
        end
        
        def load_options(options)
          @options = {
            :low_message  => default_error_message(:inclusion),
            :high_message => default_error_message(:inclusion)
          }.merge(options.extract_options!)
        end
      end

      # Ensure that the attribute is in the range specified
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:low_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
      # * <tt>:high_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
      #
      # Example:
      #   it { should ensure_value_in_range(:age, 1..100) }
      #
      def ensure_value_in_range(attribute, range, *options)
        EnsureValueInRange.new(attribute, range, *options)
      end
    end
  end
end