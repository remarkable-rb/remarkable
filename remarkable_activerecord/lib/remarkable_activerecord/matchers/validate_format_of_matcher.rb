module Remarkable
  module ActiveRecord
    module Matchers
      class ValidateFormatOfMatcher < EnsureValuesInListMatcher
      end

      # Ensures that the attribute can be set to the given values.
      #
      # Note: this matcher accepts at once just one attribute to test.
      # Note: this matcher is also aliased as "allow_values_for".
      #
      # == Options
      #
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.invalid')</tt>
      #
      # == Examples
      #
      #   should_validate_format_of :isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0"
      #   should_not_validate_format_of :isbn, "bad 1", "bad 2"
      #
      #   it { should validate_format_of(:isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0") }
      #   it { should_not validate_format_of(:isbn, "bad 1", "bad 2") }
      #
      def validate_format_of(attribute, *args)
        options = args.extract_options!
        ValidateFormatOfMatcher.new(:invalid, attribute, options.merge!(:in => args)).spec(self)
      end
      alias :allow_values_for :validate_format_of

    end
  end
end
