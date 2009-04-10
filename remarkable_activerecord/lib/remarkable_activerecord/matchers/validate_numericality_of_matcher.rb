module Remarkable
  module ActiveRecord
    module Matchers
      class ValidateNumericalityOfMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :collection => :attributes, :as => :attribute

        optional :equal_to, :greater_than_or_equal_to, :greater_than,
                 :less_than_or_equal_to, :less_than, :message

        optional :only_integer, :odd, :even, :allow_nil, :allow_blank, :default => true

        collection_assertions :only_numeric_values?, :allow_blank?, :allow_nil?,
                              :only_integer?, :only_odd?, :only_even?, :equals_to?,
                              :less_than_minimum?, :more_than_maximum?

        # Before assertions, we rearrange the values.
        #
        # Notice that :less_than gives a maximum value while :more_than given
        # a minimum value. While :equal_to generate both.
        #
        before_assert do
          @maximum_values = {}
          @minimum_values = {}

          if value = @options[:equal_to]
            @maximum_values[:equal_to] = value
            @minimum_values[:equal_to] = value
          elsif value = @options[:less_than]
            @maximum_values[:less_than] = value - 1
          elsif value = @options[:greater_than]
            @minimum_values[:greater_than] = value + 1
          elsif value = @options[:less_than_or_equal_to]
            @maximum_values[:less_than_or_equal_to] = value
          elsif value = @options[:greater_than_or_equal_to]
            @minimum_values[:greater_than_or_equal_to] = value
          end
        end

        private

          def allow_nil?
            super(default_message_for(:not_a_number))
          end

          def allow_blank?
            super(default_message_for(:not_a_number))
          end

          def only_numeric_values?
            bad?("abcd", default_message_for(:not_a_number))
          end

          def only_integer?
            assert_bad_or_good_if_key(:only_integer, valid_value_for_test.to_f, default_message_for(:not_a_number))
          end

          # In ActiveRecord, when we supply :even, does not matter the value, it
          # considers that should even values should be accepted.
          #
          def only_even?
            return true unless @options[:even]
            bad?(even_valid_value_for_test + 1, default_message_for(:even))
          end

          # In ActiveRecord, when we supply :odd, does not matter the value, it
          # considers that should odd values should be accepted.
          #
          def only_odd?
            return true unless @options[:odd]
            bad?(even_valid_value_for_test, default_message_for(:odd))
          end

          # Check equal_to for all registered values.
          #
          def equals_to?
            values = {}
            @maximum_values.each { |k, v| values[k] = v }
            @minimum_values.each { |k, v| values[k] = v }

            values.each do |key, value|
              return false, :count => value unless good?(value, default_message_for(key))
            end
            true
          end

          # Check more_than_maximum? for equal_to, less_than and
          # less_than_or_equal_to options.
          #
          def more_than_maximum?
            @maximum_values.each do |key, value|
              return false, :count => value unless bad?(value + 1, default_message_for(key))
            end
            true
          end

          # Check less_than_minimum? for equal_to, more_than and
          # more_than_or_equal_to options.
          #
          def less_than_minimum?
            @minimum_values.each do |key, value|
              return false, :count => value unless bad?(value - 1, default_message_for(key))
            end
            true
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

          # Returns the default message for each key (:odd, :even, :equal_to, ...).
          # If the user provided a message, we use it, otherwise we should use
          # the given key as message.
          #
          # For example, a default_message_for(:odd), if none is provided, will be
          # :odd. So we have create :odd_message in the options hash, that when
          # called later, will return :odd.
          #
          def default_message_for(key)
            if @options[:message]
              :message
            else
              @options[:"#{key}_message"] = key
              :"#{key}_message"
            end
          end
      end

      # Ensures that the given attributes accepts only numbers.
      #
      # == Options
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
      # == Examples
      #
      #   should_validate_numericality_of :age, :price
      #   should_validate_numericality_of :price, :only_integer => false, :greater_than => 10
      #
      #   it { should validate_numericality_of(:age).odd }
      #   it { should validate_numericality_of(:age).even }
      #   it { should validate_numericality_of(:age).only_integer }
      #   it { should validate_numericality_of(:age, :odd => true) }
      #   it { should validate_numericality_of(:age, :even => true) }
      #
      def validate_numericality_of(*attributes)
        ValidateNumericalityOfMatcher.new(*attributes).spec(self)
      end

    end
  end
end
