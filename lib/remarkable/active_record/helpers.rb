module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Helpers # :nodoc:
      include Remarkable::Default::Helpers
      
      def pretty_error_messages(obj) # :nodoc:
        obj.errors.map do |a, m| 
          msg = "#{a} #{m}" 
          msg << " (#{obj.send(a).inspect})" unless a.to_sym == :base
        end
      end

      def get_instance_of(object_or_klass) # :nodoc:
        if object_or_klass.is_a?(Class)
          klass = object_or_klass
          instance_variable_get("@#{klass.to_s.underscore}") || klass.new
        else
          object_or_klass
        end
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
      def assert_good_value(object_or_klass, attribute, value, error_message_to_avoid = //) # :nodoc:
        object = get_instance_of(object_or_klass)
        object.send("#{attribute}=", value)

        return true if object.valid?
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
      def assert_bad_value(object_or_klass, attribute, value,
                           error_message_to_expect = self.class.default_error_message(:invalid)) # :nodoc:
        object = get_instance_of(object_or_klass)
        object.send("#{attribute}=", value)
        
        return false if object.valid?
        return false unless object.errors.on(attribute)
        
        assert_contains(object.errors.on(attribute), error_message_to_expect)
      end

      # Helper method that determines the default error message used by Active
      # Record.  Works for both existing Rails 2.1 and Rails 2.2 with the newly
      # introduced I18n module used for localization.
      #
      #   default_error_message(:blank)
      #   default_error_message(:too_short, :count => 5)
      #   default_error_message(:too_long, :count => 60)
      def default_error_message(key, values = {}) # :nodoc:
        if Object.const_defined?(:I18n) # Rails >= 2.2
          I18n.translate("activerecord.errors.messages.#{key}", values)
        else # Rails <= 2.1.x
          ::ActiveRecord::Errors.default_error_messages[key] % values[:count]
        end
      end
    end
  end
end
