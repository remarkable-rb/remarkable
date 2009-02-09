module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class EnsureValueInListMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, behavior, *good_values)
          @behavior = behavior
          load_options(good_values.extract_options!)

          @attribute = attribute
          @good_values = good_values
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@good_values) do |good_value|
            @good_value = good_value
            value_valid?
          end &&
          assert_matcher do
            @good_value = 'nil'
            allow_nil?
          end &&
          assert_matcher do
            @good_value = 'blank'
            allow_blank?
          end
        end

        def description
          values = @good_values.dup
          values << 'nil'   if @options[:allow_nil]
          values << 'blank' if @options[:allow_blank]

          if @behavior == :invalid
            "allow #{@attribute} to be set to #{values.to_sentence}"
          else
            "ensure #{@behavior} of #{values.to_sentence} in #{@attribute}"
          end
        end

        def failure_message
          "Expected to #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect to #{expectation}"
        end

        private

        def load_options(options = {})
          @options = {
            :message => @behavior
          }.merge(options)
        end

        def value_valid?
          if @behavior == :exclusion
            return true if bad?(@good_value)
            @missing = "#{@attribute} can be set to #{@good_value.inspect}"
          else
            return true if good?(@good_value)
            @missing = "#{@attribute} cannot be set to #{@good_value.inspect}"
          end

          false
        end

        def expectation
          if @behavior == :invalid
            "allow #{@attribute} to be set to #{@good_value.inspect}"
          else
            "validate #{@behavior} of #{@good_value.inspect} in #{@attribute}"
          end
        end
      end

    end
  end
end
