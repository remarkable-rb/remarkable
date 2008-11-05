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
