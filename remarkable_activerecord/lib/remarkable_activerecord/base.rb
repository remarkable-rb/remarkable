module Remarkable
  module ActiveRecord
    class Base < Remarkable::Base

      protected

        # Before each assertion, get an instance of the @subject. Although this
        # is not needed in theory, we will keep it since subject are still
        # experimental on rspec.
        #
        def before_assert
          @subject = get_instance_of(@subject)
        end

        # Get a instance of the given object or class. If a class is given, it
        # will check if a instance variable of this class is already set.
        #
        def get_instance_of(object_or_klass) # :nodoc:
          if object_or_klass.is_a?(Class)
            klass = object_or_klass
            object = @spec ? @spec.instance_variable_get("@#{instance_variable_name_for(klass)}") : nil
            object ||= klass.new
          else
            object_or_klass
          end
        end

        # Guess instance variable name
        #
        def instance_variable_name_for(klass)
          klass.to_s.split('::').last.underscore
        end

        # Checks for the given key in @options, if it exists and it's true,
        # tests that the value is bad, otherwise tests that the value is good.
        #
        # It accepts the key to check for, the value that is used for testing
        # and an @options key where the message to search for is.
        #
        def assert_bad_or_good_if_key(key, value, message_key=:message) #:nodoc:
          return true unless @options.key? key

          if @options[key]
            return true if bad?(value, message_key)
            return false, :not => ''
          else
            return true if good?(value, message_key)
            return false, :not => not_word
          end
        end

        # Checks for the given key in @options, if it exists and it's true,
        # tests that the value is good, otherwise tests that the value is bad.
        #
        # It accepts the key to check for, the value that is used for testing
        # and an @options key where the message to search for is.
        #
        def assert_good_or_bad_if_key(key, value, message_key=:message) #:nodoc:
          return true unless @options.key? key

          if @options[key]
            return true if good?(value, message_key)
            return false, :not => not_word
          else
            return true if bad?(value, message_key)
            return false, :not => ''
          end
        end

        # Default allow_nil? validation. It accepts the message_key which is
        # the key which contain the message in @options.
        #
        # It also gets an allow_nil message on remarkable.active_record.allow_nil
        # to be used as default.
        #
        def allow_nil?(message_key=:message) #:nodoc:
          bool, options = assert_good_or_bad_if_key(:allow_nil, nil, message_key)

          unless bool
            default = Remarkable.t "remarkable.active_record.allow_nil", default_i18n_options.except(:scope).merge(options)
            return false, options.merge(:default => default)
          end

          true
        end

        # Default allow_blank? validation. It accepts the message_key which is
        # the key which contain the message in @options.
        #
        # It also gets an allow_blank message on remarkable.active_record.allow_blank
        # to be used as default.
        #
        def allow_blank?(message_key=:message) #:nodoc:
          bool, options = assert_good_or_bad_if_key(:allow_blank, '', message_key)

          unless bool
            default = Remarkable.t "remarkable.active_record.allow_blank", default_i18n_options.except(:scope).merge(options)
            return false, options.merge(:default => default)
          end

          true
        end

        # Shortcut for assert_good_value.
        #
        def good?(value, message_sym=:message) #:nodoc:
          assert_good_value(@subject, @attribute, value, @options[message_sym])
        end

        # Shortcut for assert_bad_value.
        #
        def bad?(value, message_sym=:message) #:nodoc:
          assert_bad_value(@subject, @attribute, value, @options[message_sym])
        end

        # Asserts that an Active Record model validates with the passed
        # <tt>value</tt> by making sure the <tt>error_message_to_avoid</tt> is not
        # contained within the list of errors for that attribute.
        #
        #   assert_good_value(User.new, :email, "user@example.com")
        #   assert_good_value(User.new, :ssn, "123456789", /length/)
        #
        # If a class is passed as the first argument, a new object will be
        # instantiated before the assertion.  If an instance variable exists with
        # the same name as the class (underscored), that object will be used
        # instead.
        #
        #   assert_good_value(User, :email, "user@example.com")
        #
        #   @product = Product.new(:tangible => false)
        #   assert_good_value(Product, :price, "0")
        #
        def assert_good_value(model, attribute, value, error_message_to_avoid=//) # :nodoc:
          model.send("#{attribute}=", value)

          return true if model.valid?

          error_message_to_avoid = error_message_from_model(model, attribute, error_message_to_avoid)
          assert_does_not_contain(model.errors.on(attribute), error_message_to_avoid)
        end

        # Asserts that an Active Record model invalidates the passed
        # <tt>value</tt> by making sure the <tt>error_message_to_expect</tt> is
        # contained within the list of errors for that attribute.
        #
        #   assert_bad_value(User.new, :email, "invalid")
        #   assert_bad_value(User.new, :ssn, "123", /length/)
        #
        # If a class is passed as the first argument, a new object will be
        # instantiated before the assertion.  If an instance variable exists with
        # the same name as the class (underscored), that object will be used
        # instead.
        #
        #   assert_bad_value(User, :email, "invalid")
        #
        #   @product = Product.new(:tangible => true)
        #   assert_bad_value(Product, :price, "0")
        #
        def assert_bad_value(model, attribute, value, error_message_to_expect=:invalid) #:nodoc:
          model.send("#{attribute}=", value)

          return false if model.valid? || model.errors.on(attribute).blank?

          error_message_to_expect = error_message_from_model(model, attribute, error_message_to_expect)
          assert_contains(model.errors.on(attribute), error_message_to_expect)
        end

        # Return the error message to be checked. If the message is not a Symbol
        # neither a Hash, it returns the own message.
        #
        # But the nice thing is that when the message is a Symbol we get the error
        # messsage from within the model, using already existent structure inside
        # ActiveRecord.
        #
        # This allows a couple things from the user side:
        #
        #   1. Specify symbols in their tests:
        #
        #     should_allow_values_for(:shirt_size, 'S', 'M', 'L', :message => :inclusion)
        #
        #   As we know, allow_values_for searches for a :invalid message. So if we
        #   were testing a validates_inclusion_of with allow_values_for, previously
        #   we had to do something like this:
        #
        #     should_allow_values_for(:shirt_size, 'S', 'M', 'L', :message => 'not included in list')
        #
        #   Now everything gets resumed to a Symbol.
        #
        #   2. Do not worry with specs if their are using I18n API properly.
        #
        #   As we know, I18n API provides several interpolation options besides
        #   fallback when creating error messages. If the user changed the message,
        #   macros would start to pass when they shouldn't.
        #
        #   Using the underlying mechanism inside ActiveRecord makes us free from
        #   all thos errors.
        #
        # We replace {{count}} interpolation for __count__ which later is
        # replaced by a regexp which contains \d+.
        #
        def error_message_from_model(model, attribute, message) #:nodoc:
          if message.is_a? Symbol
            message = if Object.const_defined?(:I18n) # Rails >= 2.2
              model.errors.generate_message(attribute, message, :count => '__count__')
            else # Rails <= 2.1
              ::ActiveRecord::Errors.default_error_messages[message] % '__count__'
            end

            if message =~ /__count__/
              message = Regexp.escape(message)
              message.gsub!('__count__', '\d+')
              message = /#{message}/
            end
          end

          message
        end

        # Asserts that the given collection does not contain item x. If x is a
        # regular expression, ensure that none of the elements from the collection
        # match x.
        #
        def assert_does_not_contain(collection, x) #:nodoc:
          !assert_contains(collection, x)
        end

    end
  end
end
