module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class EnsureValueInRangeMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        arguments :attribute, :behavior, :ranges

        def low_message(message)
          warn "[DEPRECATION] should_ensure_value_in_range.low_message is deprecated. " <<
               "Use should_validate_inclusion_of.message instead."
          @options[:low_message] = message
          self
        end

        def high_message(message)
          warn "[DEPRECATION] should_ensure_value_in_range.high_message is deprecated. " <<
               "Use should_validate_inclusion_of.message instead."
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

        assertions :less_than_minimum?, :accepts_minimum?, :more_than_minimum?, :allow_nil?,
                   :more_than_maximum?, :accepts_maximum?, :less_than_maximum?, :allow_blank?

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

        def default_options
          { :low_message  => @behavior,
            :high_message => @behavior,
            :message      => @behavior }
        end
      end

      # TODO Deprecate this method, but not the matcher.
      def ensure_value_in_range(attribute, range, *options) #:nodoc:
        hash_options = options.extract_options!

        warn "[DEPRECATION] should_ensure_value_in_range with :low_message is deprecated. " <<
             "Use should_validate_inclusion_of with :message instead." if hash_options[:low_message]

        warn "[DEPRECATION] should_ensure_value_in_range with :high_message is deprecated. " <<
             "Use should_validate_inclusion_of with :message instead." if hash_options[:high_message]

        warn "[DEPRECATION] should_ensure_value_in_range is deprecated. " <<
             "Use should_validate_inclusion_of instead." if hash_options[:low_message].blank? && hash_options[:high_message].blank?

        EnsureValueInRangeMatcher.new(attribute, :inclusion, range, *options)
      end
    end
  end
end
