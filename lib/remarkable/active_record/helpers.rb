module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Helpers # :nodoc:
      include Remarkable::Default::Helpers

      def message(value)
        @options[:message] = value
        self
      end

      def allow_nil(value = true)
        @options[:allow_nil] = value
        self
      end

      def allow_blank(value = true)
        @options[:allow_blank] = value
        self
      end

      protected

      def pretty_error_messages(obj) # :nodoc:
        obj.errors.map do |a, m| 
          msg = "#{a} #{m}" 
          msg << " (#{obj.send(a).inspect})" unless a.to_sym == :base
        end
      end

      # Get a instance of the given objecy or class.
      #
      # If a class is given, it will check if a instance variable of this class
      # is already set.
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

      # Common structure of tests that has been refactored.
      # It checks for the key, if it exists and it's true, tests that the value
      # given is bad, otherwise tests that the value is good.
      #
      def assert_bad_or_good_if_key(key, value, missing, message_key = :message)
        return true unless @options.key? key

        if @options[key]
          return true if bad?(value, message_key)
        else
          return true if good?(value, message_key)
          missing = 'not ' + missing
        end

        @missing = missing
        false
      end

      # Common structure of tests that has been refactored.
      # It checks for the key, if it exists and it's true, tests that the value
      # given is good, otherwise tests that the value is bad.
      #
      def assert_good_or_bad_if_key(key, value, missing, message_key = :message)
        return true unless @options.key? key

        if @options[key]
          return true if good?(value, message_key)
          missing = 'not ' + missing
        else
          return true if bad?(value, message_key)
        end

        @missing = missing
        false
      end

      # Default allow_nil? validation.
      #
      # Notice that it checks for @options[:message], so be sure that this option
      # is properly set.
      #
      def allow_nil?(message_key = :message)
        message = "allow #{@attribute} be set to nil"
        assert_good_or_bad_if_key(:allow_nil, nil, message, message_key)
      end

      # Default allow_blank? validation.
      #
      # Notice that it checks for @options[:message], so be sure that this option
      # is properly set.
      #
      def allow_blank?(message_key = :message)
        message = "allow #{@attribute} be set to blank"
        assert_good_or_bad_if_key(:allow_blank, '', message, message_key)
      end

      # Shortcut for assert_good_value.
      # Please notice that it has instance variables hard coded. So do not use
      # it if you are trying to assert another instance besides @subject.
      #
      def good?(value, message_sym = :message)
        assert_good_value(@subject, @attribute, value, @options[message_sym])
      end

      # Shortcut for assert_bad_value.
      # Please notice that it has instance variables hard coded. So do not use
      # it if you are trying to assert another instance besides @subject.
      #
      def bad?(value, message_sym = :message)
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
      def assert_good_value(object_or_klass, attribute, value, error_message_to_avoid = //) # :nodoc:
        object = get_instance_of(object_or_klass)
        object.send("#{attribute}=", value)

        return true if object.valid?

        error_message_to_avoid = error_message_from_model(object, attribute, error_message_to_avoid)

        assert_does_not_contain(object.errors.on(attribute), error_message_to_avoid)
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
      def assert_bad_value(object_or_klass, attribute, value, error_message_to_expect = :invalid) # :nodoc:
        object = get_instance_of(object_or_klass)
        object.send("#{attribute}=", value)
        
        return false if object.valid?
        return false unless object.errors.on(attribute)

        error_message_to_expect = error_message_from_model(object, attribute, error_message_to_expect)

        assert_contains(object.errors.on(attribute), error_message_to_expect)
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

    end
  end
end
