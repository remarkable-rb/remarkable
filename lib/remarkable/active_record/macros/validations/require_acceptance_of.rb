module Remarkable
  module Syntax

    module RSpec
      class RequireAcceptanceOf
        include Remarkable::Private
        
        def initialize(*attributes)
          @message = get_options!(attributes, :message)
          @message ||= default_error_message(:accepted)

          @attributes = attributes
        end

        def matches?(klass)
          @klass = klass

          begin
            @attributes.each do |attribute|
              return false unless assert_bad_value(klass, attribute, false, @message)
            end

            true
          rescue Exception => e
            false
          end
        end

        def description
          "require #{@attributes.to_sentence} to be accepted"
        end

        def failure_message
          message = "expected that the #{@klass.name} cannot be saved if #{@attributes.to_sentence} "
          message += @attributes.size > 1 ? "are" : "is"
          message += " not accepted, but it did"
          message
        end

        def negative_failure_message
          message = "expected that the #{@klass.name} can be saved if #{@attributes.to_sentence} "
          message += @attributes.size > 1 ? "are" : "is"
          message += " not accepted, but it didn't"
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
      #   it { should require_acceptance_of(:eula) }
      #
      def require_acceptance_of(*attributes)
        Remarkable::Syntax::RSpec::RequireAcceptanceOf.new(*attributes)
      end
    end

    module Shoulda
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
      #   should_require_acceptance_of :eula
      #
      def should_require_acceptance_of(*attributes)
        message = get_options!(attributes, :message)
        message ||= default_error_message(:accepted)
        klass = model_class

        attributes.each do |attribute|
          it "should require #{attribute} to be accepted" do
            assert_bad_value(klass, attribute, false, message).should be_true
          end
        end
      end
    end

  end
end
