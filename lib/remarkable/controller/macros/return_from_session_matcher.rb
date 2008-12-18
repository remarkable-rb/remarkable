module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class ReturnFromSession < Remarkable::Matcher::Base
        include Remarkable::Controller::Helpers
        
        def initialize(key, expected)
          @key      = key
          @expected = expected
        end

        def matches?(subject)
          @subject = subject
          
          assert_matcher do
            has_session_key?
          end
        end

        def description
          expectation
        end

        def failure_message
          @missing
        end
        
        private
        
        def has_session_key?
          instantiate_variables_from_assigns do
            expected_value = eval(@expected, self.send(:binding), __FILE__, __LINE__)
            return true if @session[@key] == expected_value
            
            @missing = "Expected #{expected_value.inspect} but was #{@session[@key]}"
            return false
          end
        end
        
        def expectation
          "return the correct value from the session for key #{@key}"
        end
      end

      def return_from_session(key, expected)
        ReturnFromSession.new(key, expected)
      end
    end
  end
end