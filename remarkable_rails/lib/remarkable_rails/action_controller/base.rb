module Remarkable
  module ActionController
    class Base < Remarkable::Base

      before_assert :perform_action_with_macro_stubs

      protected

        # Before assertions, check if the controller already performed an action.
        #
        # So the first step is to find the controller. If we find it, we see if
        # it already performed and, if not, we call run_action! in the @spec
        # binding.
        #
        def perform_action_with_macro_stubs
          controller = if @subject.class.ancestors.include?(ActionController::Base)
            @subject
          elsif @spec.instance_variable_get('@controller')
            @spec.instance_variable_get('@controller')
          end

          @spec.send(:run_action!) unless controller && controller.send(:performed?)
        rescue Exception => e
          nil
        end

    end
  end
end
