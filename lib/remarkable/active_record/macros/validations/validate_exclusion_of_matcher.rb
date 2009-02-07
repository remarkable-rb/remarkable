module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      # Ensures that given values are not valid for the attribute.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Example:
      #
      #   it { should validate_exclusion_of(:username, "admin", "user") }
      #   it { should_not validate_exclusion_of(:username, "dhh", "peter_park") }
      #
      #   it { should validate_exclusion_of(:age, 30..60) }
      #
      def validate_exclusion_of(attribute, *good_values)
        # If the first good_values is a range, we should redirect to ensure_value_in_range_matcher.
        if good_values.first.is_a? Range
          EnsureValueInRangeMatcher.new(attribute, :exclusion, *good_values)
        else
          ValidateInclusionOfMatcher.new(attribute, :exclusion, *good_values)
        end
      end
      alias :ensure_exclusion_of :validate_exclusion_of
    end
  end
end
