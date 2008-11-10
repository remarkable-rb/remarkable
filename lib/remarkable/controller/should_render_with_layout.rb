# Macro that creates a test asserting that the controller rendered with the given layout.
# Example:
#
#   should_render_with_layout 'special'
def should_render_with_layout(expected_layout = 'application')
  if expected_layout
    should "render with #{expected_layout.inspect} layout" do
      response_layout = @response.layout.blank? ? "" : @response.layout.split('/').last
      assert_equal expected_layout.to_s,
                   response_layout,
                   "Expected to render with layout #{expected_layout} but was rendered with #{response_layout}"
    end
  else
    should "render without layout" do
      assert_nil @response.layout,
                 "Expected no layout, but was rendered using #{@response.layout}"
    end
  end
end