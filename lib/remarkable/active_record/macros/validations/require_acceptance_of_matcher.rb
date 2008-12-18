module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class RequireAcceptanceOf < Remarkable::Matcher::Base
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
            require_accepted?
          end
        end

        def description
          "require #{@attributes.to_sentence} to be accepted"
        end
        
        private
        
        def require_accepted?
          return true if assert_bad_value(@subject, @attribute, false, @options[:message])
          
          @missing = "not require #{@attribute} to be accepted"
          return false
        end
        
        def load_options(options)
          @options = {
            :message => default_error_message(:accepted)
          }.merge(options)
        end
        
        def expectation
          "that the #{model_name} cannot be saved if #{@attribute} is not accepted"
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
      #   it { should require_acceptance_of(:eula) }
      #
      def require_acceptance_of(*attributes)
        RequireAcceptanceOf.new(*attributes)
      end
    end
  end
end
