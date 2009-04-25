module Remarkable
  module ActiveRecord
    module Matchers
      class ValidateAcceptanceOfMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :collection => :attributes, :as => :attribute

        optional :accept, :message
        optional :allow_nil, :default => true

        collection_assertions :requires_acceptance?, :accept_is_valid?, :allow_nil?

        default_options :message => :accepted

        protected

          def requires_acceptance?
            bad?(false)
          end

          def accept_is_valid?
            return true unless @options.key?(:accept)
            good?(@options[:accept])
          end

      end

      # Ensures that the model cannot be saved if one of the attributes listed is not accepted.
      #
      # == Options
      #
      # * <tt>:accept</tt> - the expected value to be accepted.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.accepted')</tt>
      #
      # == Examples
      #
      #   should_validate_acceptance_of :eula, :terms
      #   should_validate_acceptance_of :eula, :terms, :accept => true
      #
      #   it { should validate_acceptance_of(:eula, :terms) }
      #   it { should validate_acceptance_of(:eula, :terms, :accept => true) }
      #
      def validate_acceptance_of(*attributes, &block)
        ValidateAcceptanceOfMatcher.new(*attributes, &block).spec(self)
      end

    end
  end
end
