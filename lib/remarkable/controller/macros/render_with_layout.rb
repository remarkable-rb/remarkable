module Remarkable
  module Syntax

    module RSpec
      # Macro that creates a test asserting that the controller rendered with the given layout.
      # Example:
      #
      #   it { should render_with_layout('special') }
      #   it { should render_with_layout(:special) }
      # 
      def render_with_layout(expected_layout = 'application')
        if expected_layout
          simple_matcher "render with #{expected_layout.inspect} layout" do |controller|
            response_layout = response.layout.blank? ? "" : response.layout.split('/').last
            response_layout.should == expected_layout.to_s
          end
        else
          simple_matcher "render without layout" do
            response.layout.should be_nil
          end
        end
      end

      # Macro that creates a test asserting that the controller rendered without a layout.
      # Same as @it { should render_with_layout(false) }@
      def render_without_layout
        simple_matcher "render without layout" do |controller|
          controller.should render_with_layout(nil)
        end
      end
    end

    module Shoulda
      # Macro that creates a test asserting that the controller rendered with the given layout.
      # Example:
      #
      #   should_render_with_layout 'special'
      #   should_render_with_layout :special
      # 
      def should_render_with_layout(expected_layout = 'application')
        if expected_layout
          it "should render with #{expected_layout.inspect} layout" do
            response_layout = response.layout.blank? ? "" : response.layout.split('/').last
            response_layout.should == expected_layout.to_s
          end
        else
          it "should render without layout" do
            response.layout.should be_nil
          end
        end
      end

      # Macro that creates a test asserting that the controller rendered without a layout.
      # Same as @should_render_with_layout false@
      def should_render_without_layout
        should_render_with_layout nil
      end
    end

  end
end
