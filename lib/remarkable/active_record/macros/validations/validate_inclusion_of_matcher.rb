module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      # Ensures that given values are valid for the attribute. If a range
      # is given, ensures that the attribute is valid in the given range.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Note: this matcher accepts at once just one attribute to test.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
      #
      # Example:
      #
      #   it { should validate_inclusion_of(:isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0") }
      #   it { should_not validate_inclusion_of(:isbn, "bad 1", "bad 2") }
      #
      #   it { should validate_inclusion_of(:age, 18..100) }
      #
      def validate_inclusion_of(attribute, *good_values)
        if good_values.first.is_a? Range
          EnsureValueInRangeMatcher.new(attribute, :inclusion, *good_values)
        else
          EnsureValueInListMatcher.new(attribute, :inclusion, *good_values)
        end
      end
      alias :allow_inclusion_of  :validate_inclusion_of
      alias :ensure_inclusion_of :validate_inclusion_of

    end
  end
end
