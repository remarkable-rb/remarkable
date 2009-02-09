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

        def accept(value)
          @options[:accept] = value
          self
        end

        def matches?(subject)
          @subject = subject
          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            allow_nil? && require_accepted? && accept_is_valid?
          end
        end

        def description
          message = "require #{@attributes.to_sentence} to be accepted"
          message << " or nil" if @options[:nil]
          message
        end

        private

        def require_accepted?
          return true if bad?(false)

          @missing = "not require #{@attribute} to be accepted"
          return false
        end

        def accept_is_valid?
          return true unless @options.key? :accept
          return true if good?(@options[:accept])

          @missing = "is not accepted when #{@attribute} is #{@options[:accept].inspect}"
          false
        end

        # Receives a Hash
        def load_options(options = {})
          @options = {
            :message => :accepted
          }.merge(options)
        end

        def expectation
          message = "that the #{subject_name} can be saved if #{@attribute} is accepted"
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
      # * <tt>:accept</tt> - the expected value to be accepted.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.accepted')</tt>
      #
      # Example:
      #   it { should validate_acceptance_of(:eula, :terms) }
      #   it { should validate_acceptance_of(:eula, :terms, :accept => true) }
      #
      def validate_acceptance_of(*attributes)
        ValidateAcceptanceOfMatcher.new(*attributes)
      end
      alias :require_acceptance_of :validate_acceptance_of
    end
  end
end
