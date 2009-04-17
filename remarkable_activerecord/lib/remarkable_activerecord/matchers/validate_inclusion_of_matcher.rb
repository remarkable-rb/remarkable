require File.join(File.dirname(__FILE__), 'allow_values_for_matcher')

module Remarkable
  module ActiveRecord
    module Matchers
      class ValidateInclusionOfMatcher < AllowValuesForMatcher #:nodoc:

        default_options :message => :inclusion

        protected

          def valid_values
            @options[:in]
          end

          def invalid_values
            if @in_range
              [ @options[:in].first - 1, @options[:in].last + 1 ]
            elsif @options[:in].empty?
              []
            else
              [ @options[:in].map(&:to_s).max.to_s.next ]
            end
          end

      end

      # Ensures that given values are valid for the attribute. If a range
      # is given, ensures that the attribute is valid in the given range.
      #
      # If you give that :size accepts ["S", "M", "L"], it will test that "T"
      # (the next of the array max value) is not allowed.
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
        ValidateInclusionOfMatcher.new(*args).spec(self)
      end

    end
  end
end
