module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class SetSessionMatcher < Remarkable::Matcher::Base
        include Remarkable::Controller::Helpers
        
        def initialize(key, expected=nil, &block)
          @key      = key
          @expected = expected
          @expected = block if block_given?
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
          expected_value = if @expected.is_a?(Proc)
            @spec.instance_eval &@expected
          else
            warn "[DEPRECATION] Strings given to should_set_session won't be evaluated anymore. Give a block or a proc instead."
            @spec.instance_eval(@expected) rescue @expected
          end
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

      def set_session(key, expected=nil, &block)
        SetSessionMatcher.new(key, expected, &block)
      end

      def return_from_session(*args, &block)
        warn "[DEPRECATION] should_return_from_session is deprecated. Use should_set_session instead."
        set_session(*args, &block)
      end
    end
  end
end
