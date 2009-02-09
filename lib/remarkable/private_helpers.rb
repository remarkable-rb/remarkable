module Remarkable # :nodoc:
  module Private # :nodoc:    
    # Returns the model class constant, as determined by the test class name.
    def subject_class
      # TODO: fazer um mixin na classe de string para retornar o formato do variable_name
      variable_name = "@#{instance_variable_name}"
      if instance_variable_defined?(variable_name)
        instance_variable_get(variable_name)
      else
        self.class.described_type
      end
    end

    def instance_variable_name
      self.class.described_type.to_s.split(':').last.underscore
    end
  end
end
