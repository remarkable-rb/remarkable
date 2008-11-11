include Remarkable::Controller::Helpers



# Macro that creates a test asserting that the controller did not assign to
# any of the named instance variable(s).
#
# Example:
#
#   should_not_assign_to :user, :posts
# 
def should_not_assign_to(*names)
  names.each do |name|
    it "should not assign to @#{name}" do
      assigns(name.to_sym).should be_nil
    end
  end
end

# Macro that creates a test asserting that the rendered view contains a <form> element.
def should_render_a_form
  it "should display a form" do
    response.should have_tag("form")
  end
end

# Macro that creates a test asserting that the controller responded with a 'response' status code.
# Example:
#
#   should_respond_with :success
# 
def should_respond_with(type)
  it "respond with #{type}" do
    clean_backtrace do
      if [ :success, :missing, :redirect, :error ].include?(type) && response.send("#{type}?")
      elsif type.is_a?(Fixnum) && response.response_code == type
      elsif type.is_a?(Symbol) && response.response_code == ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[type]
      else
        if response.error?
          exception = response.template.instance_variable_get(:@exception)
          exception_message = exception && exception.message
          Spec::Expectations.fail_with "Expected response to be a #{type}, but was #{response.response_code}\n#{exception_message.to_s}"
        else
          Spec::Expectations.fail_with "Expected response to be a #{type}, but was #{response.response_code}"
        end
      end
    end
  end
end

# Macro that creates a test asserting that the response content type was 'content_type'.
# Example:
#
#   should_respond_with_content_type 'application/rss+xml'
#   should_respond_with_content_type :rss
#   should_respond_with_content_type /rss/
# 
def should_respond_with_content_type(content_type)
  it "should respond with content type of #{content_type}" do
    content_type = Mime::EXTENSION_LOOKUP[content_type.to_s].to_s if content_type.is_a? Symbol
    if content_type.is_a? Regexp
      response.content_type.should match(content_type)
    else
      response.content_type.should == content_type
    end
  end
end

# Macro that creates a test asserting that the controller rendered the given template.
# Example:
#
#   should_render_template :new
# 
def should_render_template(template)
  it "should render template #{template.inspect}" do
    it { response.should render_template(template.to_s) }
  end
end

# Macro that creates a test asserting that the controller returned a redirect to the given path.
# The given string is evaled to produce the resulting redirect path.  All of the instance variables
# set by the controller are available to the evaled string.
# Example:
#
#   should_redirect_to '"/"'
#   should_redirect_to "user_url(@user)"
#   should_redirect_to "users_url"
# 
def should_redirect_to(url)
  it "should redirect to #{url.inspect}" do
    instantiate_variables_from_assigns do
      response.should redirect_to(eval(url, self.send(:binding), __FILE__, __LINE__))
    end
  end
end

# :section: Test macros
# Macro that creates a test asserting that the flash contains the given value.
# val can be a String, a Regex, or nil (indicating that the flash should not be set)
#
# Example:
#
#   should_set_the_flash_to "Thank you for placing this order."
#   should_set_the_flash_to /created/i
#   should_set_the_flash_to nil
# 
def should_set_the_flash_to(val)
  if val
    it "should have #{val.inspect} in the flash" do
      assert_contains(flash.values, val)
    end
  else
    it "should not set the flash" do
      assert_equal({}, flash)
    end
  end
end

# Macro that creates a test asserting that the flash is empty.  Same as
# @should_set_the_flash_to nil@
def should_not_set_the_flash
  should_set_the_flash_to nil
end

# Macro that creates a test asserting that filter_parameter_logging
# is set for the specified keys
#
# Example:
#
#   should_filter_params :password, :ssn
# 
def should_filter_params(*keys)
  keys.each do |key|
    it "should filter #{key}" do
      controller.should respond_to(:filter_parameters)
      filtered = controller.send(:filter_parameters, {key.to_s => key.to_s})
      filtered[key.to_s].should == '[FILTERED]'
    end
  end
end

# Macro that creates a test asserting that a value returned from the session is correct.
# The given string is evaled to produce the resulting redirect path.  All of the instance variables
# set by the controller are available to the evaled string.
# Example:
#
#   should_return_from_session :user_id, '@user.id'
#   should_return_from_session :message, '"Free stuff"'
# 
def should_return_from_session(key, expected)
  it "should return the correct value from the session for key #{key}" do
    instantiate_variables_from_assigns do
      expected_value = eval(expected, self.send(:binding), __FILE__, __LINE__)
      session[key].should == expected_value
    end
  end
end
