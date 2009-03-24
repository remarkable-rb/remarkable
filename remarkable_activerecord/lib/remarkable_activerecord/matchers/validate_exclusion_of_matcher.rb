module Remarkable
  module ActiveRecord
    module Matchers

      # Ensures that given values are not valid for the attribute. If a range
      # is given, ensures that the attribute is not valid in the given range.
      #
      # This matcher has to now before hand if it's working with lists or ranges.
      # So you can not do:
      #
      #   validate_exclusion_of(:size).in("S", "M", "L", "XL")
      #
      # This is a limitation craeted to gain performance in tests.
      #
      # == Options
      #
      # * <tt>:in</tt> - values to test exclusion.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.exclusion')</tt>
      #
      # == Examples
      #
      #   it { should validate_exclusion_of(:username, :in => ["admin", "user"]) }
      #   it { should validate_exclusion_of(:age, :in => 30..60) }
      #
      #   should_validate_exclusion_of :username, :in => ["admin", "user"]
      #   should_validate_exclusion_of :age, :in => 30..60
      #
      def validate_exclusion_of(*args)
        raise ArgumentError, 'You have to give me the values to test exclusion in ' <<
                             'validate_exclusion_of' unless args.last.is_a?(Hash)

        if args.last[:in].is_a?(Range)
          EnsureValuesInRangeMatcher.new(:exclusion, *args).spec(self)
        else
          EnsureValuesInListMatcher.new(:exclusion, *args).spec(self)
        end
      end

    end
  end
end
