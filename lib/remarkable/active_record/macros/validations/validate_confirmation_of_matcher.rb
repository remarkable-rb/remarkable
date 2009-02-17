module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateConfirmationOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        undef_method :allow_nil?, :allow_nil, :allow_blank?, :allow_blank

        arguments :attributes
        assertions :confirmed?

        def description
          "validate confirmation of #{@attributes.to_sentence}"
        end

        private

        # Before make the assertions, convert the subject into a instance, if
        # it's not already.
        #
        def before_assert
          @subject = get_instance_of(@subject)
        end

        def default_options
          { :message => :confirmation }
        end

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
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.confirmation')</tt>
      #
      # Example:
      #   it { should validate_confirmation_of(:email, :password) }
      #
      def validate_confirmation_of(*attributes)
        ValidateConfirmationOfMatcher.new(*attributes)
      end

    end
  end
end
