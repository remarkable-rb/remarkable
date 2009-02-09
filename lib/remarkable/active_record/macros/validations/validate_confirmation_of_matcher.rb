module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateConfirmationOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        undef_method :allow_nil?, :allow_nil, :allow_blank?, :allow_blank

        def initialize(*attributes)
          load_options(attributes.extract_options!)
          @attributes = attributes
        end

        def matches?(subject)
          @subject = get_instance_of(subject)

          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            confirmed?
          end
        end

        def description
          "ensure confirmation of #{@attributes.to_sentence}"
        end

        private

        def confirmed?
          confirmation_assignment = "#{@attribute}_confirmation="

          if @subject.respond_to? confirmation_assignment
            @subject.send(confirmation_assignment, 'something')
            return true if bad?('different')

            @missing = "#{subject_name} is valid even if confirmation does not match"
            return false
          else
            @missing = "#{subject_name} does not respond to #{confirmation_assignment}"
            return false
          end
        end

        def load_options(options = {})
          @options = {
            :message => :confirmation
          }.merge(options)
        end

        def expectation
          "#{@attribute} to be confirmed"
        end
      end

      # Ensures that the model cannot be saved if one of the attributes is not confirmed.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.confirmation')</tt>
      #
      # Example:
      #   it { should validate_confirmation_of(:email, :password) }
      #
      def validate_confirmation_of(*attributes)
        ValidateConfirmationOfMatcher.new(*attributes)
      end
      alias :ensure_confirmation_of :validate_confirmation_of

    end
  end
end
