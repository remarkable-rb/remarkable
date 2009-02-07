module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class EnsureValueInRangeMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, behavior, range, *options)
          @attribute = attribute
          @range     = range
          @behavior  = behavior
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
            if @behavior == :inclusion
              less_than_minimum? && accepts_minimum? &&
              more_than_maximum? && accepts_maximum?
            elsif @behavior == :exclusion
              more_than_minimum? && accepts_minimum? &&
              less_than_maximum? && accepts_maximum?
            end
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
          "that the #{@attribute} is #{'not ' if @behavior == :exclusion}in #{@range}"
        end

        # -----------------------------
        # validate_inclusion_of methods
        # -----------------------------
        def less_than_minimum?
          return true if assert_bad_value(@subject, @attribute, (@range.first - 1), @options[:low_message])

          @missing = "allow #{@attribute} to be less than #{@range.first}"
          return false
        end

        def more_than_maximum?
          return true if assert_bad_value(@subject, @attribute, (@range.last + 1), @options[:high_message])
          
          @missing = "allow #{@attribute} to be more than #{@range.last}"
          return false
        end

        # -----------------------------
        # validate_exclusion_of methods
        # -----------------------------
        def less_than_maximum?
          return true if assert_bad_value(@subject, @attribute, (@range.last - 1), @options[:low_message])

          @missing = "allow #{@attribute} to be less than #{@range.last}"
          return false
        end

        def more_than_minimum?
          return true if assert_bad_value(@subject, @attribute, (@range.first + 1), @options[:high_message])
          
          @missing = "allow #{@attribute} to be more than #{@range.first}"
          return false
        end

        # --------------
        # Common methods
        # --------------
        def accepts_minimum?
          return true if assert_boundary_value(@subject, @attribute, @range.first, @options[:low_message])

          @missing = create_boundary_message("allow #{@attribute} to be #{@range.first}")
          return false
        end

        def accepts_maximum?
          return true if assert_boundary_value(@subject, @attribute, @range.last, @options[:high_message])

          @missing = create_boundary_message("allow #{@attribute} to be #{@range.last}")
          return false
        end

        # Create a message based on the behavior (inclusion or exclusion).
        #
        # Let's suppose the following validation:
        #
        #   validate_inclusion_of :age, 18..100
        #
        # If eventually :age cannot be a 100, the message should be:
        #
        #   (not allow :age to be 100)
        #
        # When we have:
        #
        #   validate_exclusion_of :age, 18..100
        #
        # If eventually :age can be a 100, the message should be:
        #
        #   (allow :age to be 100)
        #
        def create_boundary_message(message)
          if @behavior == :exclusion
            message
          else
            "not " << message
          end
        end

        def assert_boundary_value(*args)
          if @behavior == :exclusion
            assert_bad_value(*args)
          else
            assert_good_value(*args)
          end
        end

        def load_options(options)
          @options = {
            :low_message  => @behavior,
            :high_message => @behavior
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
      # TODO This matcher should be deprecated in a sense that should not have
      # an API. But it will be internally used by validate_inclusion_of,
      # validate_exclusion_of and validate_numericality_of matchers.
      #
      # We should also deprecate :low_message and :high_message since they don't
      # make sense in validate_inclusion_of or validate_exclusion_of matchers. By
      # doing this we can refactor accepts_maximum? and accepts_minimum? into a
      # single assert_boundary method.
      #
      def ensure_value_in_range(attribute, range, *options)
        EnsureValueInRangeMatcher.new(attribute, :inclusion, range, *options)
      end
    end
  end
end
