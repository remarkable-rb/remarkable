module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidatePresenceOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        undef_method :allow_blank?, :allow_blank, :allow_nil

        arguments  :attributes
        optional   :message
        assertions :allow_nil?

        def description
          "require #{@attributes.to_sentence} to be set"
        end

        private

        def default_options
          { :message => :blank, :allow_nil => false }
        end

        def expectation
          "that the #{subject_name} cannot be saved if #{@attribute} is not present"
        end
      end

      # Ensures that the model cannot be saved if one of the attributes listed is not present.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.blank')</tt>
      #
      # Example:
      #   it { should validate_presence_of(:name, :phone_number) }
      #
      def validate_presence_of(*attributes)
        ValidatePresenceOfMatcher.new(*attributes)
      end

      # TODO Deprecate me
      def require_attributes(*attributes) #:nodoc:
        warn "[DEPRECATION] should_require_attributes is deprecated. " <<
             "Use should_validate_presence_of instead."
        ValidatePresenceOfMatcher.new(*attributes)
      end

    end
  end
end
