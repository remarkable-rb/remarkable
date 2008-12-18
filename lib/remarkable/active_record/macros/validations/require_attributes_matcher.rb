module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class RequireAttributes < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(*attributes)
          load_options(attributes.extract_options!)
          @attributes = attributes
        end

        def message(message)
          @options[:message] = message
          self
        end

        def matches?(subject)
          @subject = subject
          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            require_set?
          end
        end

        def description
          "require #{@attributes.to_sentence} to be set"
        end

        private

        def require_set?
          return true if assert_bad_value(@subject, @attribute, nil, @options[:message])

          @missing = "not require #{@attribute} to be set"
          return false
        end

        def load_options(options)
          @options = {
            :message => default_error_message(:blank)
          }.merge(options)
        end

        def expectation
          "that the #{model_name} cannot be saved if #{@attribute} is not present"
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
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.blank')</tt>
      #
      # Example:
      #   it { should require_attributes(:name, :phone_number) }
      #
      def require_attributes(*attributes)
        RequireAttributes.new(*attributes)
      end
    end
  end
end
