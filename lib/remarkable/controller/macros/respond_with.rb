module Remarkable
  module Syntax

    module RSpec
      class RespondWith
        include Remarkable::Private

        def initialize(response, type)
          @response = response
          @type = type
        end

        def matches?(controller)
          @controller = controller

          begin
            if [ :success, :missing, :redirect, :error ].include?(@type) && @response.send("#{@type}?")
            elsif @type.is_a?(Fixnum) && @response.response_code == @type
            elsif @type.is_a?(Symbol) && @response.response_code == ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[@type]
            else
              if @response.error?
                exception = @response.template.instance_variable_get(:@exception)
                exception_message = exception && exception.message
                fail "Expected response to be a #{@type}, but was #{@response.response_code}\n#{exception_message.to_s}"
              else
                fail "Expected response to be a #{@type}, but was #{@response.response_code}"
              end
            end

            true
          rescue Exception => e
            false
          end
        end

        def description
          "respond with #{@type}"
        end

        def failure_message
          @failure_message || "expected respond with #{@type}, but it didn't"
        end

        def negative_failure_message
          "expected not respond with #{@type}, but it did"
        end
      end

      # Macro that creates a test asserting that the controller responded with a 'response' status code.
      # Example:
      #
      #   it { should respond_with(:success) }
      #
      def respond_with(type)
        Remarkable::Syntax::RSpec::RespondWith.new(response, type)
      end
    end

    module Shoulda
      # Macro that creates a test asserting that the controller responded with a 'response' status code.
      # Example:
      #
      #   should_respond_with :success
      # 
      def should_respond_with(type)
        it "respond with #{type}" do
          clean_backtrace do
            if [ :success, :missing, :redirect, :error ].include?(type) && response.send("#{type}?")
            elsif type.is_a?(Fixnum) && response.response_code == type
            elsif type.is_a?(Symbol) && response.response_code == ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[type]
            else
              if response.error?
                exception = response.template.instance_variable_get(:@exception)
                exception_message = exception && exception.message
                Spec::Expectations.fail_with "Expected response to be a #{type}, but was #{response.response_code}\n#{exception_message.to_s}"
              else
                Spec::Expectations.fail_with "Expected response to be a #{type}, but was #{response.response_code}"
              end
            end
          end
        end
      end
    end

  end
end
