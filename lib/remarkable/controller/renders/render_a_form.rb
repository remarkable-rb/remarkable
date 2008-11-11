# Macro that creates a test asserting that the rendered view contains a <form> element.
def render_a_form
  simple_matcher "should display a form" do |controller|
    controller.response.should have_tag("form")
  end
end

# Macro that creates a test asserting that the rendered view contains a <form> element.
def should_render_a_form
  it "should display a form" do
    response.should have_tag("form")
  end
end
