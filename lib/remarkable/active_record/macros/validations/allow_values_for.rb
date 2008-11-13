module Remarkable
  module Syntax

    module RSpec
      class AllowValuesFor
        include Remarkable::Private
        
        def initialize(attribute, *good_values)
          get_options!(good_values)

          @attribute = attribute
          @good_values = good_values
        end

        def matches?(klass)
          @klass = klass

          begin
            @good_values.each do |v|
              return false unless assert_good_value(klass, @attribute, v)
            end

            true
          rescue Exception => e
            false
          end
        end

        def description
          "allow #{@attribute} to be set to #{@good_values.to_sentence}"
        end

        def failure_message
          "expected allow #{@attribute} to be set to #{@good_values.to_sentence}, but it didn't"
        end

        def negative_failure_message
          "expected allow #{@attribute} not to be set to #{@good_values.to_sentence}, but it did"
        end
      end

      # Ensures that the attribute can be set to the given values.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Example:
      #   it { should allow_values_for(:isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0") }
      #   it { should_not allow_values_for(:isbn, "bad 1", "bad 2") }
      #
      def allow_values_for(attribute, *good_values)
        Remarkable::Syntax::RSpec::AllowValuesFor.new(attribute, *good_values)
      end
    end

    module Shoulda
      # Ensures that the attribute can be set to the given values.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Example:
      #   should_allow_values_for :isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0"
      #
      def should_allow_values_for(attribute, *good_values)
        get_options!(good_values)
        klass = model_class
        good_values.each do |v|
          it "should allow #{attribute} to be set to #{v.inspect}" do
            assert_good_value(klass, attribute, v).should be_true
          end
        end
      end
      
      # Ensures that the attribute cannot be set to the given values
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.invalid')</tt>
      #
      # Example:
      #   should_not_allow_values_for :isbn, "bad 1", "bad 2"
      #
      def should_not_allow_values_for(attribute, *bad_values)
        message = get_options!(bad_values, :message)
        message ||= default_error_message(:invalid)
        klass = model_class
        bad_values.each do |v|
          it "should not allow #{attribute} to be set to #{v.inspect}" do
            assert_bad_value(klass, attribute, v, message).should be_true
          end
        end
      end
    end

  end
end
