module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class RespondWith < Remarkable::Matcher::Base
        def initialize(type)
          @type = type
        end

        def matches?(subject)
          @subject = subject

          initialize_with_spec!

          assert_matcher do
            respond_with_type?
          end
        end

        def description
          expectation
        end

        def failure_message
          @missing
        end
        
        private
        
        def respond_with_type?
          return true if [:success, :missing, :redirect, :error].include?(@type) && @response.send("#{@type}?")
          return true if @type.is_a?(Fixnum) && @response.response_code == @type
          return true if @type.is_a?(Symbol) && @response.response_code == ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[@type]
          
          @missing = if @response.error?
            exception = @response.template.instance_variable_get(:@exception)
            exception_message = exception && exception.message
            "Expected response to be a #{@type}, but was #{@response.response_code}\n#{exception_message.to_s}"
          else
            "Expected response to be a #{@type}, but was #{@response.response_code}"
          end
          return false
        end

        def initialize_with_spec!
          # In Rspec 1.1.12 we can actually do:
          #
          #   @response = @subject.response
          #
          @response = @spec.instance_eval { response }
        end

        def expectation
          "respond with #{@type}"
        end
      end
      
      def respond_with(type)
        RespondWith.new(type)
      end
    end
  end
end
