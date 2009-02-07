module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class RespondWithContentType < Remarkable::Matcher::Base
        def initialize(content_type)
          @content_type = content_type
        end

        def matches?(subject)
          @subject = subject

          initialize_with_spec!

          assert_matcher do
            content_type_correct?
          end
        end

        def description
          expectation
        end

        def failure_message
          @missing
        end

        private

        def initialize_with_spec!
          # In Rspec 1.1.12 we can actually do:
          #
          #   @response = @subject.response
          #
          @response = @spec.instance_eval { response }
        end

        def content_type_correct?
          @content_type = Mime::EXTENSION_LOOKUP[@content_type.to_s].to_s if @content_type.is_a?(Symbol)
          if @content_type.is_a?(Regexp)
            return true if @response.content_type =~ @content_type
            @missing = "Expected to match #{@content_type} but was actually #{@response.content_type}"
          else
            return true if @response.content_type == @content_type
            @missing = "Expected #{@content_type} but was actually #{@response.content_type}"
          end
          return false
        end
        
        def expectation
          "respond with content type of #{@content_type}"
        end

      end

      def respond_with_content_type(content_type)
        RespondWithContentType.new(content_type)
      end
    end
  end
end
