include Remarkable::Controller::Helpers

# Macro that creates a routing test. It tries to use the given HTTP
# +method+ on the given +path+, and asserts that it routes to the
# given +options+.
#
# +to_param+ is called on the +options+ given.
#
# Examples:
#
#   should_route :get, "/posts", :controller => :posts, :action => :index
#   should_route :get, "/posts/new", :controller => :posts, :action => :new
#   should_route :post, "/posts", :controller => :posts, :action => :create
#   should_route :get, "/posts/1", :controller => :posts, :action => :show, :id => 1
#   should_route :edit, "/posts/1", :controller => :posts, :action => :show, :id => 1
#   should_route :put, "/posts/1", :controller => :posts, :action => :update, :id => 1
#   should_route :delete, "/posts/1", :controller => :posts, :action => :destroy, :id => 1
#   should_route :get, "/users/1/posts/1",
#     :controller => :posts, :action => :show, :id => 1, :user_id => 1
#
def should_route(method, path, params)
  populated_path = path.dup

  params[:controller] = params[:controller].to_s
  params[:action] = params[:action].to_s

  params.each do |key, value|
    params[key] = value.to_param if value.respond_to? :to_param
    populated_path.gsub!(key.inspect, value.to_s)
  end

  it "should map #{params.inspect} to #{path.inspect}" do
    route_for(params).should == populated_path
  end

  it "should generate params #{params.inspect} from #{method.to_s.upcase} to #{path.inspect}" do
    params_from(method.to_sym, populated_path).should == params
  end
end

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

# Macro that creates a test asserting that the controller assigned to
# each of the named instance variable(s).
#
# Options:
# * <tt>:class</tt> - The expected class of the instance variable being checked.
# * <tt>:equals</tt> - A string which is evaluated and compared for equality with
# the instance variable being checked.
#
# Example:
#
#   should_assign_to :user, :posts
#   should_assign_to :user, :class => User
#   should_assign_to :user, :equals => '@user'
# 
def should_assign_to(*names)
  opts = names.extract_options!
  names.each do |name|
    test_name = "should assign @#{name}"
    test_name << " as class #{opts[:class]}" if opts[:class]
    test_name << " which is equal to #{opts[:equals]}" if opts[:equals]
    it test_name do
      assigned_value = assigns(name.to_sym)
      assigned_value.should_not be_nil
      assigned_value.should be_a_kind_of(opts[:class]) if opts[:class]
      if opts[:equals]
        instantiate_variables_from_assigns do
          expected_value = eval(opts[:equals], self.send(:binding), __FILE__, __LINE__)
          assigned_value.should == expected_value
        end
      end
    end
  end
end

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
