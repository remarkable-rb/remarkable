module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      # Ensures that given values are not valid for the attribute. If a range
      # is given, ensures that the attribute is not valid in the given range.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Note: this matcher accepts at once just one attribute to test.
      #
      # Options:
      #
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.exclusion')</tt>
      #
      # Example:
      #
      #   it { should validate_exclusion_of(:username, "admin", "user") }
      #   it { should_not validate_exclusion_of(:username, "clark_kent", "peter_park") }
      #
      #   it { should validate_exclusion_of(:age, 30..60) }
      #
      def validate_exclusion_of(attribute, *good_values)
        if good_values.first.is_a? Range
          EnsureValueInRangeMatcher.new(attribute, :exclusion, *good_values)
        else
          EnsureValueInListMatcher.new(attribute, :exclusion, *good_values)
        end
      end

    end
  end
end
