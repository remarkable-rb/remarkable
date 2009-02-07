module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class EnsureLengthInRangeMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, range, behavior, *options)
          @attribute = attribute
          @behavior  = behavior

          if @behavior == :within
            @min_value = range.first
            @max_value = range.last
          elsif @behavior == :minimum
            @min_value = range
          elsif @behavior == :maximum
            @max_value = range
          end

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
          return true if @behavior == :maximum && @min_value <= 0

          min_value = "x" * (@min_value - 1)
          return true if assert_bad_value(@subject, @attribute, min_value, @options[:short_message])

          @missing = "allow #{@attribute} to be less than #{@min_value} chars long"
          return false
        end

        def exactly_min_length?
          return true if @behavior == :maximum && @min_value <= 0
          
          min_value = "x" * @min_value
          return true if assert_good_value(@subject, @attribute, min_value, @options[:short_message])
          
          @missing = "not allow #{@attribute} to be exactly #{@min_value} chars long"
          return false
        end

        def more_than_max_length?
          return true if @behavior == :minimum

          max_value = "x" * (@max_value + 1)
          return true if assert_bad_value(@subject, @attribute, max_value, @options[:long_message])

          @missing = "allow #{@attribute} to be more than #{@max_value} chars long"
          return false
        end
        
        def exactly_max_length?
          return true if @behavior == :minimum

          max_value = "x" * @max_value
          return true if assert_good_value(@subject, @attribute, max_value, @options[:long_message])

          @missing = "not allow #{@attribute} to be exactly #{@max_value} chars long"
          return false
        end
        
        def load_options(options)
          @options = {
            :short_message => { :too_short => { :count => @min_value } },
            :long_message => { :too_long => { :count => @max_value } }
          }.merge(options.extract_options!)
        end
        
        def expectation
          message = "that the length of the #{@attribute} is "

          message << if @behavior == :within
            "between #{@min_value} and #{@max_value}"
          elsif @behavior == :minimum
            "more than #{@min_value}"
          elsif @behavior == :maximum
            "less than #{@max_value}"
          end

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
      #
      #   it { should ensure_length_in_range(:password, 6..20) }
      #
      def ensure_length_in_range(attribute, range, *options)
        EnsureLengthInRangeMatcher.new(attribute, range, :within, *options)
      end

      def ensure_length_at_least(attribute, range, *options)
        EnsureLengthInRangeMatcher.new(attribute, range, :minimum, *options)
      end

      def ensure_length_no_more(attribute, range, *options)
        EnsureLengthInRangeMatcher.new(attribute, range, :maximum, *options)
      end
    end
  end
end
