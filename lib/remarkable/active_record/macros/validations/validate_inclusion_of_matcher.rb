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
      #
      # * <tt>:in</tt> - values to test inclusion.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
      #
      # Example:
      #
      #   it { should validate_inclusion_of(:size, :in => ["S", "M", "L", "XL"]) }
      #   it { should validate_inclusion_of(:age, 18..100) }
      #
      #   should_validate_inclusion_of :size, :in => ["S", "M", "L", "XL"]
      #   should_validate_inclusion_of :age, :in => 18..100
      #
      def validate_inclusion_of(attribute, *good_values)
        # TODO Remove this until the next comment
        options = good_values.extract_options!

        unless options.key?(:in) || good_values.empty?
          warn "[DEPRECATION] Please use validate_inclusion_of #{attribute.inspect}, :in => #{good_values[0..-2].inspect} " <<
               "instead of validate_inclusion_of #{attribute.inspect}, #{good_values[0..-2].inspect[1..-2]}."
        end

        options[:in] ||= good_values

        # From now on is what should be the actual method.
        good_values = [options.delete(:in)].flatten.compact
        good_values << options

        if good_values.first.is_a? Range
          EnsureValueInRangeMatcher.new(attribute, :inclusion, *good_values)
        else
          EnsureValueInListMatcher.new(attribute, :inclusion, *good_values)
        end
      end

      # TODO This one is for shoulda compatibility. Deprecate it?
      def ensure_inclusion_of(attribute, *good_values) #:nodoc:
        warn "[DEPRECATION] should_ensure_inclusion_of is deprecated. " <<
             "Use should_validate_inclusion_of instead."
        validate_inclusion_of(attribute, *good_values)
      end

    end
  end
end
