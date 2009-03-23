module Remarkable
  module ActiveRecord
    module Matchers
      class ValidateConfirmationOfMatcher < Remarkable::ActiveRecord::Base

        arguments :collection => :attributes, :as => :attribute

        optional :allow_nil, :allow_blank, :default => true
        collection_assertions :respond_to_confirmation?, :confirm?, :allow_nil?, :allow_blank?

        default_options :message => :confirmation

        protected

        def respond_to_confirmation?
          @subject.respond_to?(:"#{@attribute}_confirmation=")
        end

        def confirm?
          @subject.send(:"#{@attribute}_confirmation=", 'something')
          bad?('different')
        end

      end

      # Ensures that the model cannot be saved if one of the attributes is not confirmed.
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
