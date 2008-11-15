module Remarkable
  module ActiveRecord
    module Syntax

      module RSpec
        class RequireAttributes
          include Remarkable::Private
          include Remarkable::ActiveRecord::Helpers

          def initialize(*attributes)
            @message = get_options!(attributes, :message)
            @message ||= default_error_message(:blank)

            @attributes = attributes
          end

          def matches?(klass)
            @klass = klass

            begin
              @attributes.each do |attribute|
                return false unless assert_bad_value(klass, attribute, nil, @message)
              end

              true
            rescue Exception => e
              false
            end
          end

          def description
            "require #{@attributes.to_sentence} to be set"
          end

          def failure_message
            message = "expected that the #{@klass.name} cannot be saved if #{@attributes.to_sentence} "
            message += @attributes.size > 1 ? "are" : "is"
            message += " not present, but it did"
            message
          end

          def negative_failure_message
            message = "expected that the #{@klass.name} can be saved if #{@attributes.to_sentence} "
            message += @attributes.size > 1 ? "are" : "is"
            message += " not present, but it didn't"
            message
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
          Remarkable::ActiveRecord::Syntax::RSpec::RequireAttributes.new(*attributes)
        end
      end

      module Shoulda
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
        #   should_require_attributes :name, :phone_number
        #
        def should_require_attributes(*attributes)
          message = get_options!(attributes, :message)
          message ||= default_error_message(:blank)
          klass = model_class

          attributes.each do |attribute|
            it "should require #{attribute} to be set" do
              assert_bad_value(klass, attribute, nil, message).should be_true
            end
          end
        end
      end

    end
  end
end
