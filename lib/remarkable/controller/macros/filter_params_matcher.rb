module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class FilterParams < Remarkable::Matcher::Base
        include Remarkable::Controller::Helpers

        def initialize(*keys)
          @options = keys.extract_options!
          @keys    = keys
        end

        def matches?(subject)
          @subject = subject

          initialize_with_spec!
          
          assert_matcher_for(@keys) do |key|
            @key = key
            respond_to_filter_parameters? && is_filtered?
          end
        end

        def description
          "filter #{@keys.to_sentence}"
        end

        private

        def initialize_with_spec!
          # In Rspec 1.1.12 we can actually do:
          #
          #   @controller = @subject
          #
          @controller = @spec.instance_eval { controller }
        end

        def respond_to_filter_parameters?
          return true if @controller.respond_to?(:filter_parameters)
          
          @missing = "The key #{@key} is not filtered"
          return false
        end

        def is_filtered?
          filtered = @controller.send(:filter_parameters, { @key.to_s => @key.to_s })
          return true if filtered[@key.to_s] == '[FILTERED]'
          
          @missing = "The key #{@key} is not filtered"
          return false
        end

        def expectation
          "filter #{@key}"
        end

      end

      def filter_params(*keys)
        FilterParams.new(*keys)
      end
    end
  end
end
