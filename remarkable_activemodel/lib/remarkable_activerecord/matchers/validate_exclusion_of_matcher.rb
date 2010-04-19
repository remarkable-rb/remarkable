require File.join(File.dirname(__FILE__), 'allow_values_for_matcher')

module Remarkable
  module ActiveRecord
    module Matchers
      class ValidateExclusionOfMatcher < AllowValuesForMatcher #:nodoc:
        # Don't allow it to behave in the negative way.
        undef_method :does_not_match?

        default_options :message => :exclusion

        protected

          def valid_values
            if @in_range
              [ @options[:in].first - 1, @options[:in].last + 1 ]
            else
              value = @options[:in].select{ |i| i.is_a?(String) }.max
              value ? [ value.next ] : []
            end
          end

          def invalid_values
            @options[:in]
          end

      end

      # Ensures that given values are not valid for the attribute. If a range
      # is given, ensures that the attribute is not valid in the given range.
      #
      # If you give that :username does not accept ["admin", "user"], it will
      # test that "uses" (the next of the array max value) is allowed.
      #
      # == Options
      #
      # * <tt>:in</tt> - values to test exclusion.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors[:attribute]</tt>.
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
      def validate_exclusion_of(*args, &block)
        ValidateExclusionOfMatcher.new(*args, &block).spec(self)
      end

    end
  end
end
