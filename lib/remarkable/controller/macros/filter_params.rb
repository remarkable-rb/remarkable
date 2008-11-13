module Remarkable
  module Syntax

    module RSpec
      # Macro that creates a test asserting that filter_parameter_logging
      # is set for the specified keys
      #
      # Example:
      #
      #   it { should filter_params(:password, :ssn) }
      # 
      def filter_params(*keys)
        simple_matcher "filter #{keys.to_sentence}" do
          ret = true
          keys.each do |key|
            if controller.respond_to?(:filter_parameters)
              filtered = controller.send(:filter_parameters, {key.to_s => key.to_s})
              unless filtered[key.to_s] == '[FILTERED]'
                ret = false
                break  
              end
            else
              ret = false
              break
            end
          end
          ret
        end
      end
    end

    module Shoulda
      # Macro that creates a test asserting that filter_parameter_logging
      # is set for the specified keys
      #
      # Example:
      #
      #   should_filter_params :password, :ssn
      # 
      def should_filter_params(*keys)
        keys.each do |key|
          it "should filter #{key}" do
            controller.should respond_to(:filter_parameters)
            filtered = controller.send(:filter_parameters, {key.to_s => key.to_s})
            filtered[key.to_s].should == '[FILTERED]'
          end
        end
      end
    end

  end
end