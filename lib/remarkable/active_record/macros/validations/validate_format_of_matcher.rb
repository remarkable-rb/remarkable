module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      # Ensures that the attribute can be set to the given values.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Note: this matcher accepts at once just one attribute to test.
      # Note: this matcher is also aliased as "allow_values_for"
      #
      # Options:
      #
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.invalid')</tt>
      #
      # Example:
      #
      #   it { should validate_format_of(:isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0") }
      #   it { should_not validate_format_of(:isbn, "bad 1", "bad 2") }
      #
      def validate_format_of(attribute, *good_values)
        EnsureValueInListMatcher.new(attribute, :invalid, *good_values)
      end
      alias :allow_values_for :validate_format_of

    end
  end
end
