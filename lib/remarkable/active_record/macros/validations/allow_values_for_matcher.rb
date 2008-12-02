module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class AllowValuesFor
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, *good_values)
          good_values.extract_options!

          @attribute = attribute
          @good_values = good_values
        end

        def matches?(klass)
          @klass = klass
          @good_values.each do |v|
            return false unless assert_good_value(klass, @attribute, v)
          end
          true
        end

        def description
          "allow #{@attribute} to be set to #{@good_values.to_sentence}"
        end

        def failure_message
          "expected allow #{@attribute} to be set to #{@good_values.to_sentence}, but it didn't"
        end

        def negative_failure_message
          "expected allow #{@attribute} not to be set to #{@good_values.to_sentence}, but it did"
        end
      end

      # Ensures that the attribute can be set to the given values.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Example:
      #   it { should allow_values_for(:isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0") }
      #   it { should_not allow_values_for(:isbn, "bad 1", "bad 2") }
      #
      def allow_values_for(attribute, *good_values)
        AllowValuesFor.new(attribute, *good_values)
      end
    end
  end
end
