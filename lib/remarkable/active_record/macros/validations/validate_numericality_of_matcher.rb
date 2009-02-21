module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateNumericalityOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        NUMERIC_COMPARISIONS = [:equal_to, :less_than, :greater_than, :less_than_or_equal_to, :greater_than_or_equal_to]

        arguments :attributes

        optional :only_integer, :odd, :even, :default => true
        optional :equal_to, :less_than, :greater_than, :less_than_or_equal_to, :greater_than_or_equal_to

        assertions :only_allow_numeric_values?, :allow_blank?, :allow_nil?,
                   :only_integer?, :allow_odd?, :allow_even?, :equal_to_for_each_option?,
                   :less_than_maximum_for_each_option?, :more_than_maximum_for_each_option?

        def description
          default_message + "for #{@attributes.to_sentence}"
        end

        private

        # Check equal_to? for each given option
        #
        def equal_to_for_each_option?
          equal_to?(:equal_to) && equal_to?(:less_than, -1) && equal_to?(:greater_than, +1) &&
          equal_to?(:less_than_or_equal_to) && equal_to?(:greater_than_or_equal_to)
        end

        # Check more_than_maximum? for each given option
        #
        def more_than_maximum_for_each_option?
          more_than_maximum?(:equal_to, +1) && more_than_maximum?(:less_than) &&
          more_than_maximum?(:less_than_or_equal_to, +1)
        end

        # Check less_than_maximum? for each given option
        #
        def less_than_maximum_for_each_option?
           less_than_minimum?(:equal_to, -1) && less_than_minimum?(:greater_than) &&
           less_than_minimum?(:greater_than_or_equal_to, -1)
        end

        def only_allow_numeric_values?
          return true if bad?("abcd")

          @missing = "allow non-numeric values for #{@attribute}"
          false
        end

        def only_integer?
          message = "allow non-integer values for #{@attribute}"
          assert_bad_or_good_if_key(:only_integer, valid_value_for_test.to_f, message, :message)
        end

        def allow_even?
          message = "allow even values for #{@attribute}"
          assert_bad_or_good_if_key(:even, valid_value_for_test + 1, message, default_message_for(:even))
        end

        def allow_odd?
          message = "allow odd values for #{@attribute}"
          assert_bad_or_good_if_key(:odd, even_valid_value_for_test, message, default_message_for(:odd))
        end

        def equal_to?(key, add = 0)
          return true unless @options.key?(key)
          return true if good?(@options[key] + add, default_message_for(key))

          @missing = "did not allow value equals to #{@options[key]} for #{@attribute}"
          false
        end

        def more_than_maximum?(key, add = 0)
          return true unless @options.key?(key)
          return true if bad?(@options[key] + add, default_message_for(key))

          # We should do @options[key] + add - 1 to adjust messages in less_than cases.
          @missing = "allowed value #{@options[key] + add} which is more than #{@options[key] + add - 1} for #{@attribute}"
          false
        end

        def less_than_minimum?(key, add = 0)
          return true unless @options.key?(key)
          return true if bad?(@options[key] + add, default_message_for(key))

          # We should do @options[key] + add + 1 to adjust messages in greater_than cases.
          @missing = "allowed value #{@options[key] + add} which is less than #{@options[key] + add + 1} for #{@attribute}"
          false
        end

        # Returns a valid value for test.
        #
        def valid_value_for_test
          value = @options[:equal_to] || @options[:less_than_or_equal_to] || @options[:greater_than_or_equal_to]

          value ||= @options[:less_than]    - 1 if @options[:less_than]
          value ||= @options[:greater_than] + 1 if @options[:greater_than]

          value ||= 10

          if @options[:even]
            value = (value / 2) * 2
          elsif @options[:odd]
            value = ((value / 2) * 2) + 1
          end

          value
        end

        # Returns a valid even value for test.
        # The method valid_value_for_test checks for :even option but does not
        # return necessarily an even value
        #
        def even_valid_value_for_test
          (valid_value_for_test / 2) * 2
        end

        def default_options
          options = {
            :message => :not_a_number,
            :odd_message => :odd,
            :even_message => :even
          }

          NUMERIC_COMPARISIONS.each do |key|
            options[:"#{key}_message"] = key
          end

          options
        end

        # Returns the default message for each key (:odd, :even, :equal_to, ...).
        # If the main :message is equal :not_a_number, it means the user changed
        # it so we should use it. Otherwise returns :odd_message, :even_message
        # and so on.
        #
        def default_message_for(key)
          @options[:message] == :not_a_number ? :"#{key}_message" : :message
        end

        def expectation
          default_message + "for #{@attribute}"
        end

        def default_message
          message = "only allow "
          message << "even " if @options[:even]
          message << "odd "  if @options[:odd]

          message << (@options[:only_integer] ? "integer values " : "numeric values ")

          message << NUMERIC_COMPARISIONS.map do |key|
            @options[key] ? "#{key.to_s.gsub('_', ' ')} #{@options[key]} " : nil
          end.compact.join('or ')

          message << "or nil "   if @options[:allow_nil]
          message << "or blank " if @options[:allow_blank]
          message
        end
      end

      # Ensures that the given attributes accepts only numbers.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that. Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      #
      # * <tt>:only_integer</tt> - when supplied, checks if it accepts only integers or not
      # * <tt>:odd</tt> - when supplied, checks if it accepts only odd values or not
      # * <tt>:even</tt> - when supplied, checks if it accepts only even values or not
      # * <tt>:equal_to</tt> - when supplied, checks if attributes are only valid when equal to given value
      # * <tt>:less_than</tt> - when supplied, checks if attributes are only valid when less than given value
      # * <tt>:greater_than</tt> - when supplied, checks if attributes are only valid when greater than given value
      # * <tt>:less_than_or_equal_to</tt> - when supplied, checks if attributes are only valid when less than or equal to given value
      # * <tt>:greater_than_or_equal_to</tt> - when supplied, checks if attributes are only valid when greater than or equal to given value
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.not_a_number')</tt>
      #
      # Example:
      #
      #   it { should validate_numericality_of(:age, :price) }
      #   it { should validate_numericality_of(:age, :only_integer => true) }
      #   it { should validate_numericality_of(:price, :only_integer => false) }
      #   it { should validate_numericality_of(:age).only_integer }
      #
      #   it { should validate_numericality_of(:age).odd }
      #   it { should validate_numericality_of(:age).even }
      #   it { should validate_numericality_of(:age, :odd => true) }
      #   it { should validate_numericality_of(:age, :even => true) }
      #
      def validate_numericality_of(*attributes)
        ValidateNumericalityOfMatcher.new(*attributes)
      end

      # TODO Deprecate me
      def only_allow_numeric_values_for(*attributes) #:nodoc:
        warn "[DEPRECATION] should_only_allow_numeric_values_for is deprecated. " <<
             "Use should_validate_numericality_of instead."
        ValidateNumericalityOfMatcher.new(*attributes)
      end

      # TODO Deprecate me
      def only_allow_numeric_or_blank_values_for(*attributes)
        warn "[DEPRECATION] should_only_allow_numeric_or_blank_values_for is deprecated. " <<
             "Use should_validate_numericality_of with :allow_blank => true instead."
        ValidateNumericalityOfMatcher.new(*attributes).allow_blank
      end
    end
  end
end
