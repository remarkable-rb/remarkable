module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class EnsureValueInRangeMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, behavior, range, *options)
          @attribute = attribute
          @range     = range
          @behavior  = behavior
          load_options(options.extract_options!)
        end
        
        def low_message(message)
          @options[:low_message] = message
          self
        end

        def high_message(message)
          @options[:high_message] = message
          self
        end

        # TODO Low message and High message should be deprecated (not supported by
        # Rails API). In this while, we have to hack message.
        def message(message)
          @options[:high_message] = message
          @options[:low_message]  = message
          @options[:message]      = message
          self
        end

        def matches?(subject)
          @subject = subject

          assert_matcher do
            less_than_minimum? && accepts_minimum? && more_than_minimum? && allow_nil? &&
            more_than_maximum? && accepts_maximum? && less_than_maximum? && allow_blank?
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
          message = "that the #{@attribute} is #{'not ' if @behavior == :exclusion}in #{@range}"
          message << " or is nil"   if @options[:allow_nil]
          message << " or is blank" if @options[:allow_blank]
          message
        end

        def less_than_minimum?
          return true unless @behavior == :inclusion
          return true if bad?(@range.first - 1, :low_message)

          @missing = "allow #{@attribute} to be less than #{@range.first}"
          return false
        end

        def more_than_maximum?
          return true unless @behavior == :inclusion
          return true if bad?(@range.last + 1, :high_message)
          
          @missing = "allow #{@attribute} to be more than #{@range.last}"
          return false
        end

        def less_than_maximum?
          return true unless @behavior == :exclusion
          return true if bad?(@range.last - 1, :low_message)

          @missing = "allow #{@attribute} to be less than #{@range.last}"
          return false
        end

        def more_than_minimum?
          return true unless @behavior == :exclusion
          return true if bad?(@range.first + 1, :high_message)
          
          @missing = "allow #{@attribute} to be more than #{@range.first}"
          return false
        end

        def accepts_minimum?
          return true if boundary?(@range.first, :low_message)

          @missing = create_boundary_message("allow #{@attribute} to be #{@range.first}")
          return false
        end

        def accepts_maximum?
          return true if boundary?(@range.last, :high_message)

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

        def boundary?(value, message_sym)
          if @behavior == :exclusion
            bad?(value, message_sym)
          else
            good?(value, message_sym)
          end
        end

        def load_options(options = {})
          @options = {
            :low_message  => @behavior,
            :high_message => @behavior,
            :message      => @behavior
          }.merge(options)
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
