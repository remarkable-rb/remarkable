module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Macros
      include Matchers

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
        matcher = allow_values_for(attribute, *good_values)
        it "should #{matcher.description}" do
          assert_accepts(matcher, model_class)
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
        matcher = allow_values_for(attribute, *bad_values).negative
        it "should not #{matcher.description}" do
          assert_rejects(matcher, model_class)
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
      #   should_ensure_length_at_least :name, 3
      #
      def should_ensure_length_at_least(attribute, min_length, opts = {})
        matcher = ensure_length_at_least(attribute, min_length, opts)
        it "should #{matcher.description}" do
          assert_accepts(matcher, model_class)
        end
      end

      # Ensures that the length of the attribute is in the given range
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % range.first</tt>
      # * <tt>:long_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_long') % range.last</tt>
      #
      # Example:
      #   should_ensure_length_in_range :password, (6..20)
      #
      def should_ensure_length_in_range(attribute, range, opts = {})
        matcher = ensure_length_in_range(attribute, range, opts)
        it "should #{matcher.description}" do
          assert_accepts(matcher, model_class)
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
      #   should_ensure_length_is :ssn, 9
      #
      def should_ensure_length_is(attribute, length, opts = {})
        matcher = ensure_length_is(attribute, length, opts)
        it "should #{matcher.description}" do
          assert_accepts(matcher, model_class)
        end
      end
      
      # Ensure that the attribute is in the range specified
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:low_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
      # * <tt>:high_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
      #
      # Example:
      #   should_ensure_value_in_range :age, (0..100)
      #
      def should_ensure_value_in_range(attribute, range, opts = {})
        matcher = ensure_value_in_range(attribute, range, opts)
        it "should #{matcher.description}" do
          assert_accepts(matcher, model_class)
        end
      end
      
      # Ensure that the given class methods are defined on the model.
      #
      #   should_have_class_methods :find, :destroy
      #
      def should_have_class_methods(*methods)
        matcher = have_class_methods(*methods)
        it "should #{matcher.description}" do
          assert_accepts(matcher, model_class)
        end
      end
      
      # Ensure that the given instance methods are defined on the model.
      #
      #   should_have_instance_methods :email, :name, :name=
      #
      def should_have_instance_methods(*methods)
        matcher = have_instance_methods(*methods)
        it "should #{matcher.description}" do
          assert_accepts(matcher, model_class)
        end
      end
      
      # Ensures that the attribute cannot be changed once the record has been created.
      #
      #   should_have_readonly_attributes :password, :admin_flag
      #
      def should_have_readonly_attributes(*attributes)
        matcher = have_readonly_attributes(*attributes)
        it "should #{matcher.description}" do
          assert_accepts(matcher, model_class)
        end
      end
    end
  end
end
