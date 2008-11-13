module Remarkable
  module Syntax

    module RSpec
      class EnsureLengthAtLeast
        include Remarkable::Private
        
        def initialize(attribute, min_length, opts)
          @attribute  = attribute
          @min_length = min_length
          @opts       = opts
        end

        def matches?(klass)
          @klass = klass

          begin
            valid_value = "x" * (@min_length)
            fail("not allow #{@attribute} to be at least #{@min_length} chars long") unless assert_good_value(klass, @attribute, valid_value, /is too short/)

            if @min_length > 0
              min_value = "x" * (@min_length - 1)
              fail("allow #{@attribute} to be less than #{@min_length} chars long") unless assert_bad_value(klass, @attribute, min_value, /is too short/)
            end

            true
          rescue Exception => e
            false
          end
        end

        def description
          "allow #{@attribute} to be at least #{@min_length} chars long"
        end

        def failure_message
          @failure_message || "expected allow #{@attribute} to be at least #{@min_length} chars long, but it didn't"
        end

        def negative_failure_message
          "expected not allow #{@attribute} to be at least #{@min_length} chars long, but it did"
        end
      end

      # Ensures that the length of the attribute is at least a certain length
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % min_length</tt>
      #
      # Example:
      #   it { should ensure_length_at_least(:name, 3) }
      #
      def ensure_length_at_least(attribute, min_length, opts = {})
        Remarkable::Syntax::RSpec::EnsureLengthAtLeast.new(attribute, min_length, opts)
      end
    end

    module Shoulda
      # Ensures that the length of the attribute is at least a certain length
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % min_length</tt>
      #
      # Example:
      #   should_ensure_length_at_least :name, 3
      #
      def should_ensure_length_at_least(attribute, min_length, opts = {})
        short_message = get_options!([opts], :short_message)
        short_message ||= default_error_message(:too_short, :count => min_length)

        klass = model_class

        if min_length > 0
          min_value = "x" * (min_length - 1)
          it "should not allow #{attribute} to be less than #{min_length} chars long" do
            assert_bad_value(klass, attribute, min_value, short_message).should be_true
          end
        end
        it "should allow #{attribute} to be at least #{min_length} chars long" do
          valid_value = "x" * (min_length)
          assert_good_value(klass, attribute, valid_value, short_message).should be_true
        end
      end
    end

  end
end
