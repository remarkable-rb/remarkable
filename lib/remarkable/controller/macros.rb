include Remarkable::Controller::Helpers





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
