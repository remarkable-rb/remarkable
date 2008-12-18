module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class EnsureLengthInRange < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, range, *options)
          @attribute = attribute
          @range     = range
          load_options(options)
        end

        def short_message(message)
          @options[:short_message] = message
          self
        end
        
        def long_message(message)
          @options[:long_message] = message
          self
        end

        def matches?(subject)
          @subject = subject
          
          assert_matcher do
            less_than_min_length? &&
            exactly_min_length? &&
            more_than_max_length? &&
            exactly_max_length?
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
        
        def less_than_min_length?
          return true unless @range.first > 0

          min_value = "x" * (@range.first - 1)
          return true if assert_bad_value(@subject, @attribute, min_value, @options[:short_message])

          @missing = "allow #{@attribute} to be less than #{@range.first} chars long"
          return false          
        end
        
        def exactly_min_length?
          return true unless @range.first > 0
          
          min_value = "x" * @range.first
          return true if assert_good_value(@subject, @attribute, min_value, @options[:short_message])
          
          @missing = "not allow #{@attribute} to be exactly #{@range.first} chars long"
          return false
        end
        
        def more_than_max_length?
          max_value = "x" * (@range.last + 1)
          return true if assert_bad_value(@subject, @attribute, max_value, @options[:long_message])

          @missing = "allow #{@attribute} to be more than #{@range.last} chars long"
          return false
        end
        
        def exactly_max_length?
          return true if (@range.first == @range.last)

          max_value = "x" * @range.last
          return true if assert_good_value(@subject, @attribute, max_value, @options[:long_message])

          @missing = "not allow #{@attribute} to be exactly #{@range.last} chars long"
          return false
        end
        
        def load_options(options)
          @options = {
            :short_message => remove_parenthesis(default_error_message(:too_short, :count => @range.first)),
            :long_message  => remove_parenthesis(default_error_message(:too_long,  :count => @range.last))
          }.merge(options.extract_options!)
        end
        
        def expectation
          "that the length of the #{@attribute} is in #{@range}"
        end
      end

      # Ensures that the length of the attribute is in the given range
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % range.first</tt>
      # * <tt>:long_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_long') % range.last</tt>
      #
      # Example:
      #   it { should ensure_length_in_range(:password, 6..20) }
      #
      def ensure_length_in_range(attribute, range, *options)
        EnsureLengthInRange.new(attribute, range, *options)
      end
    end
  end
end
