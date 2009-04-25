module Remarkable
  module ActionController
    module Matchers
      # Do not inherit from ActionController::Base since it don't need all macro stubs behavior.
      class FilterParamsMatcher < Remarkable::Base #:nodoc:
        arguments :collection => :params, :as => :param

        assertions :respond_to_filter_params?
        collection_assertions :is_filtered?

        protected

          def respond_to_filter_params?
            @subject.respond_to?(:filter_parameters)
          end

          def is_filtered?
            filtered = @subject.send(:filter_parameters, { @param.to_s => @param.to_s })
            filtered[@param.to_s] == '[FILTERED]'
          end

      end

      # Checks if the controller filters the given params.
      #
      # == Examples
      #
      #   should_filter_params :password
      #   should_not_filter_params :username
      #
      #   it { should filter_params(:password) }
      #   it { should_not filter_params(:username) }
      #
      def filter_params(*params, &block)
        FilterParamsMatcher.new(*params, &block).spec(self)
      end
      alias :filter_param :filter_params

    end
  end
end
