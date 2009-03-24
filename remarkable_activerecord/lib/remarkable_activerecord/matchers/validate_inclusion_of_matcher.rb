module Remarkable
  module ActiveRecord
    module Matchers

      # Ensures that given values are valid for the attribute. If a range
      # is given, ensures that the attribute is valid in the given range.
      #
      # This matcher has to now before hand if it's working with lists or ranges.
      # So you can not do:
      #
      #   validate_inclusion_of(:size).in("S", "M", "L", "XL")
      #
      # This is a limitation created to gain performance in tests.
      #
      # == Options
      #
      # * <tt>:in</tt> - values to test inclusion.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
      #
      # == Examples
      #
      #   should_validate_inclusion_of :size, :in => ["S", "M", "L", "XL"]
      #   should_validate_inclusion_of :age, :in => 18..100
      #
      #   it { should validate_inclusion_of(:size, :in => ["S", "M", "L", "XL"]) }
      #   it { should validate_inclusion_of(:age, :in => 18..100) }
      #
      def validate_inclusion_of(*args)
        raise ArgumentError, 'You have to give me the values to test inclusion in ' <<
                             'validate_inclusion_of' unless args.last.is_a?(Hash)

        if args.last[:in].is_a?(Range)
          EnsureValuesInRangeMatcher.new(:inclusion, *args).spec(self)
        else
          EnsureValuesInListMatcher.new(:inclusion, *args).spec(self)
        end
      end

    end
  end
end
