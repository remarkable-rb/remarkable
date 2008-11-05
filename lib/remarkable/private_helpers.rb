module Remarkable # :nodoc:
  module Private # :nodoc:
    # Returns the values for the entries in the args hash who's keys are listed in the wanted array.
    # Will raise if there are keys in the args hash that aren't listed.
    def get_options!(args, *wanted)
      ret  = []
      opts = (args.last.is_a?(Hash) ? args.pop : {})
      wanted.each {|w| ret << opts.delete(w)}
      raise ArgumentError, "Unsupported options given: #{opts.keys.join(', ')}" unless opts.keys.empty?
      return *ret
    end

    # Helper method that determines the default error message used by Active
    # Record.  Works for both existing Rails 2.1 and Rails 2.2 with the newly
    # introduced I18n module used for localization.
    #
    #   default_error_message(:blank)
    #   default_error_message(:too_short, :count => 5)
    #   default_error_message(:too_long, :count => 60)
    def default_error_message(key, values = {})
      if Object.const_defined?(:I18n) # Rails >= 2.2
        I18n.translate("activerecord.errors.messages.#{key}", values)
      else # Rails <= 2.1.x
        ::ActiveRecord::Errors.default_error_messages[key] % values[:count]
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
    def assert_good_value(object_or_klass, attribute, value, error_message_to_avoid = //)
      object = get_instance_of(object_or_klass)
      object.send("#{attribute}=", value)
      object.valid?
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
      error_message_to_expect = self.class.default_error_message(:invalid))
      object = get_instance_of(object_or_klass)
      object.send("#{attribute}=", value)

      return false if object.valid?
      return false unless object.errors.on(attribute)
      assert_contains(object.errors.on(attribute), error_message_to_expect)
    end

    # Asserts that the given collection contains item x.  If x is a regular expression, ensure that
    # at least one element from the collection matches x.  +extra_msg+ is appended to the error message if the assertion fails.
    #
    #   assert_contains(['a', '1'], /\d/) => passes
    #   assert_contains(['a', '1'], 'a') => passes
    #   assert_contains(['a', '1'], /not there/) => fails
    def assert_contains(collection, x)
      collection = [collection] unless collection.is_a?(Array)
      case x
      when Regexp
        return false unless collection.detect { |e| e =~ x }
      else
        return false unless collection.include?(x)
      end
      true
    end

    # Asserts that the given collection does not contain item x.  If x is a regular expression, ensure that
    # none of the elements from the collection match x.
    def assert_does_not_contain(collection, x)
      collection = [collection] unless collection.is_a?(Array)
      case x
      when Regexp
        return false if collection.detect { |e| e =~ x }
      else
        return false if collection.include?(x)
      end
      true
    end

    private

    def get_instance_of(object_or_klass)
      if object_or_klass.is_a?(Class)
        klass = object_or_klass
        instance_variable_get("@#{klass.to_s.underscore}") || klass.new
      else
        object_or_klass
      end
    end
  end
end
