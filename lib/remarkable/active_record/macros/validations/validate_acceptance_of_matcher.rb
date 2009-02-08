module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateAcceptanceOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        undef_method :allow_blank, :allow_blank?

        def initialize(*attributes)
          load_options(attributes.extract_options!)
          @attributes = attributes
        end

        def matches?(subject)
          @subject = subject
          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            allow_nil? && require_accepted?
          end
        end

        def description
          message = "require #{@attributes.to_sentence} to be accepted"
          message << " or nil" if @options[:nil]
          message
        end

        private

        def require_accepted?
          return true if assert_bad_value(@subject, @attribute, false, @options[:message])

          @missing = "not require #{@attribute} to be accepted"
          return false
        end

        # Receives a Hash
        def load_options(options = {})
          @options = {
            :message => :accepted
          }.merge(options)
        end

        def expectation
          message = "that the #{model_name} can be saved if #{@attribute} is accepted"
          message << " or nil" if @options[:allow_nil]
          message
        end
      end

      # Ensures that the model cannot be saved if one of the attributes listed is not accepted.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.accepted')</tt>
      #
      # Example:
      #   it { should validate_acceptance_of(:eula) }
      #
      def validate_acceptance_of(*attributes)
        ValidateAcceptanceOfMatcher.new(*attributes)
      end
      alias :require_acceptance_of :validate_acceptance_of
    end
  end
end
