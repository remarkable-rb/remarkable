module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class AllowValuesFor < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, *good_values)
          @attribute = attribute
          load_options(good_values.extract_options!)
          @good_values = good_values
        end

        def message(message)
          @options[:message] = message
          self
        end

        def matches?(subject)
          @subject = subject
          
          assert_matcher_for(@good_values) do |good_value|
            @good_value = good_value
            value_valid?
          end
        end

        def description
          "allow #{@attribute} to be set to #{@good_values.to_sentence}"
        end

        def failure_message
          "Expected to #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect to #{expectation}"
        end
        
        private
        
        def load_options(options)
          @options = {
            :message => default_error_message(:invalid)
          }.merge(options)
        end
        
        def value_valid?
          return true if assert_good_value(@subject, @attribute, @good_value, @options[:message])
          @missing = "#{@attribute} cannot be set to #{@good_value}"
          false
        end
        
        def expectation
          "allow #{@attribute} to be set to #{@good_value}"
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
