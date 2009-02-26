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
      # * <tt>:in</tt> - values to test exclusion.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.exclusion')</tt>
      #
      # Example:
      #
      #   it { should validate_exclusion_of(:username, :in => ["admin", "user"]) }
      #   it { should validate_exclusion_of(:age, :in => 30..60) }
      #
      #   should_validate_exclusion_of :username, :in => ["admin", "user"]
      #   should_validate_exclusion_of :age, :in => 30..60
      #
      def validate_exclusion_of(attribute, *good_values)
        # TODO Remove this until the next comment
        options = good_values.extract_options!

        unless options.key?(:in) || good_values.empty?
          warn "[DEPRECATION] Please use validate_exclusion_of #{attribute.inspect}, :in => #{good_values[0..-2].inspect} " <<
               "instead of validate_exclusion_of #{attribute.inspect}, #{good_values[0..-2].inspect[1..-2]}."
        end

        options[:in] ||= good_values

        # From now on is what should be the actual method.
        good_values = [options.delete(:in)].flatten.compact
        good_values << options

        if good_values.first.is_a? Range
          EnsureValueInRangeMatcher.new(attribute, :exclusion, *good_values)
        else
          EnsureValueInListMatcher.new(attribute, :exclusion, *good_values)
        end
      end

    end
  end
end
