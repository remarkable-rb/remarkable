module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class RenderWithLayout < Remarkable::Matcher::Base
        def initialize(expected_layout = 'application')
          @expected_layout = expected_layout
        end

        def matches?(subject)
          @subject = subject

          initialize_with_spec!

          assert_matcher do
            if @expected_layout
              with_layout?
            else
              without_layout?
            end
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

        def with_layout?
          response_layout = @response.layout.blank? ? "" : @response.layout.split('/').last
          return true if response_layout == @expected_layout.to_s
          
          @missing = "Expected to render with layout #{@expected_layout} but was rendered with #{response_layout}"
          return false
        end
        
        def without_layout?
          return true if @response.layout.nil?
          
          @missing = "Expected no layout, but was rendered using #{@response.layout}"
          return false
        end
        
        def expectation
          if @expected_layout
            "render with #{@expected_layout.inspect} layout"
          else
            "render without layout"
          end
        end

      end

      def render_with_layout(expected_layout = 'application')
        RenderWithLayout.new(expected_layout)
      end
      
      def render_without_layout
        RenderWithLayout.new(nil)
      end
    end
  end
end
