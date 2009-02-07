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

          initialize_with_spec!

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
          expected_value = @spec.instance_eval(@expected) rescue @expected
          return true if @session[@key] == expected_value

          @missing = "Expected #{expected_value.inspect} but was #{@session[@key]}"
          return false
        end

        def initialize_with_spec!
          # In Rspec 1.1.12 we can actually do:
          #
          #   @session = @subject.session
          #
          @session = @spec.instance_eval { session }
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
