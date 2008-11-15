module Remarkable
  module ActiveRecord
    module Syntax

      module RSpec
        class EnsureLengthIs
          include Remarkable::Private

          def initialize(attribute, length, opts)
            @message = get_options!([opts], :message)
            @message ||= default_error_message(:wrong_length, :count => length)

            @attribute = attribute
            @length    = length
            @opts      = opts
          end

          def matches?(klass)
            @klass = klass

            begin
              min_value = "x" * (@length - 1)
              fail("allow #{@attribute} to be less than #{@length} chars long") unless assert_bad_value(klass, @attribute, min_value, @message)

              max_value = "x" * (@length + 1)
              fail("allow #{@attribute} to be greater than #{@length} chars long") unless assert_bad_value(klass, @attribute, max_value, @message)

              valid_value = "x" * (@length)
              fail("not allow #{@attribute} to be #{@length} chars long") unless assert_good_value(klass, @attribute, valid_value, @message)

              true
            rescue Exception => e
              false
            end

          end

          def description
            "ensure that the length of the #{@attribute} is exactly #{@length} chars long"
          end

          def failure_message
            @failure_message || "expected that the length of the #{@attribute} is exactly #{@length} chars long, but it didn't"
          end

          def negative_failure_message
            "expected that the length of the #{@attribute} isn't exactly #{@length} chars long, but it did"
          end
        end

        # Ensures that the length of the attribute is exactly a certain length
        #
        # If an instance variable has been created in the setup named after the
        # model being tested, then this method will use that.  Otherwise, it will
        # create a new instance to test against.
        #
        # Options:
        # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
        #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.wrong_length') % length</tt>
        #
        # Example:
        #   it { should ensure_length_is(:ssn, 9) }
        #
        def ensure_length_is(attribute, length, opts = {})
          Remarkable::ActiveRecord::Syntax::RSpec::EnsureLengthIs.new(attribute, length, opts)
        end
      end

      module Shoulda
        # Ensures that the length of the attribute is exactly a certain length
        #
        # If an instance variable has been created in the setup named after the
        # model being tested, then this method will use that.  Otherwise, it will
        # create a new instance to test against.
        #
        # Options:
        # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
        #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.wrong_length') % length</tt>
        #
        # Example:
        #   should_ensure_length_is :ssn, 9
        #
        def should_ensure_length_is(attribute, length, opts = {})
          message = get_options!([opts], :message)
          message ||= default_error_message(:wrong_length, :count => length)

          klass = model_class

          it "should not allow #{attribute} to be less than #{length} chars long" do
            min_value = "x" * (length - 1)
            assert_bad_value(klass, attribute, min_value, message).should be_true
          end

          it "should not allow #{attribute} to be greater than #{length} chars long" do
            max_value = "x" * (length + 1)
            assert_bad_value(klass, attribute, max_value, message).should be_true
          end

          it "should allow #{attribute} to be #{length} chars long" do
            valid_value = "x" * (length)
            assert_good_value(klass, attribute, valid_value, message).should be_true
          end
        end
      end

    end
  end
end
