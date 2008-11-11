# Macro that creates a test asserting that the controller rendered without a layout.
# Same as @should_render_with_layout false@
def should_render_without_layout
  should_render_with_layout nil
end

# Macro that creates a test asserting that the controller rendered without a layout.
# Same as @it { should render_with_layout(false) }@
def render_without_layout
  simple_matcher "render without layout" do |controller|
    controller.should render_with_layout(nil)
  end
end
