module Remarkable
  module ActionController
    class Base < Remarkable::Base

      before_assert :perform_action_with_macro_stubs

      optional :with_expectations, :default => true
      optional :with_stubs,        :default => true

      protected

        # Before assertions, check if the controller already performed an action.
        #
        # So the first step is to find the controller. If we find it, we see if
        # it already performed and, if not, we call run_action! in the @spec
        # binding.
        #
        def perform_action_with_macro_stubs
          controller = @spec.instance_variable_get('@controller')
          @spec.send(:run_action!, run_with_expectations?) unless controller && controller.send(:performed?)
        rescue Exception => e
          nil
        end

        def run_with_expectations?
          if @options.key?(:with_stubs)
            !@options[:with_stubs]
          elsif @options.key?(:with_expectations)
            @options[:with_expectations]
          else
            false
          end
        end

    end
  end
end
