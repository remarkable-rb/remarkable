module Remarkable
  module Syntax

    module RSpec
      class OnlyAllowNumericValuesFor
        include Remarkable::Private
        
        def initialize(*attributes)
          @message = get_options!(attributes, :message)
          @message ||= default_error_message(:not_a_number)

          @attributes = attributes
        end

        def matches?(klass)
          @klass = klass

          begin
            @attributes.each do |attribute|
              attribute = attribute.to_sym
              return false unless assert_bad_value(klass, attribute, "abcd", @message)
            end

            true
          rescue Exception => e
            false
          end
        end

        def description
          "only allow numeric values for #{@attributes.to_sentence}"
        end

        def failure_message
          "expected only numeric values for #{@attributes.to_sentence}, but it didn't"
        end

        def negative_failure_message
          "expected not only numeric values for #{@attributes.to_sentence}, but it did"
        end
      end

      # Ensure that the attribute is numeric
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.not_a_number')</tt>
      #
      # Example:
      #   it { should only_allow_numeric_values_for(:age) }
      #
      def only_allow_numeric_values_for(*attributes)
        Remarkable::Syntax::RSpec::OnlyAllowNumericValuesFor.new(*attributes)
      end
    end

    module Shoulda
      # Ensure that the attribute is numeric
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.not_a_number')</tt>
      #
      # Example:
      #   should_only_allow_numeric_values_for :age
      #
      def should_only_allow_numeric_values_for(*attributes)
        message = get_options!(attributes, :message)
        message ||= default_error_message(:not_a_number)
        klass = model_class
        attributes.each do |attribute|
          attribute = attribute.to_sym
          it "should only allow numeric values for #{attribute}" do
            assert_bad_value(klass, attribute, "abcd", message).should be_true
          end
        end
      end
    end

  end
end
