module Remarkable # :nodoc:
  module Private # :nodoc:    
    # Returns the values for the entries in the args hash who's keys are listed in the wanted array.
    # Will raise if there are keys in the args hash that aren't listed.
    # def get_options!(args, *wanted)
    #   ret  = []
    #   opts = (args.last.is_a?(Hash) ? args.pop : {})
    #   wanted.each {|w| ret << opts.delete(w)}
    #   raise ArgumentError, "Unsupported options given: #{opts.keys.join(', ')}" unless opts.keys.empty?
    #   return *ret
    # end

    # Returns the model class constant, as determined by the test class name.
    def model_class
      variable_name = "@#{self.class.described_type.to_s.underscore}"
      if instance_variable_defined?(variable_name)
        instance_variable_get(variable_name)
      else
        self.class.described_type
      end
    end
  end
end
