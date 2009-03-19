module Remarkable
  module ActionController
    module Matchers
      class RespondWithMatcher < Remarkable::ActionController::Base #:nodoc:
        arguments :expected

        assertions :status_match?

        before_assert do
          @response = @subject.respond_to?(:response) ? @subject.response : @subject
        end

        protected

          def status_match?
            case @expected
              when :success, :missing, :redirect, :error
                @response.send("#{@expected}?")
              when Fixnum
                @response.response_code == @expected
              when Symbol, String
                @response.response_code == ::ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[@expected.to_sym]
              when Range
                @expected.include?(@response.response_code)
              else
                raise ArgumentError, "I don't know how to interpret respond_with(#{@expected.inspect}), " <<
                                     "with a #{@expected.class.name} as argument."
            end
          end

          def interpolation_options
            { :expected => (@expected.is_a?(Symbol) ? @expected.to_s : @expected).inspect,
              :actual   => (@response ? @response.response_code.inspect : '') }
          end

      end

      # Passes if the response has the given status. Status can be a Symbol like
      # :success, :missing, :redirect and :error. Can be also a Fixnum, Range or
      # any other symbol which matches to any of Rails status codes. 
      #
      # == Examples
      #
      #   should_respond_with :success
      #   should_respond_with :error
      #   should_respond_with 301
      #   should_respond_with 300..399
      #
      #   it { should respond_with(:success) }
      #   it { should respond_with(:error) }
      #   it { should respond_with(301) }
      #   it { should respond_with(300..399) }
      #
      def respond_with(status)
        RespondWithMatcher.new(status).spec(self)
      end

    end
  end
end
