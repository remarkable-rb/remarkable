h1. Controller macros

For each example below, we will show you the Rspec way and in the Macro (Shoulda) way. Choose the one that pleases you the most. :)

h2. assign_to

Macro that creates a test asserting that the controller assigned to each of the named instance variable(s).

Options:

    * :class - The expected class of the instance variable being checked.
    * :equals - A string or a proc which is evaluated and compared with the instance variable being checked.

Example:

<pre><code>  should_assign_to :user, :posts
  should_assign_to :user, :class => User
  should_assign_to :user, :equals => proc { @user }
  should_assign_to(:user){ @user }
  should_not_assign_to :user, :posts

  it { should assign_to(:user, :posts) }
  it { should assign_to(:user, :class => User) }
  it { should assign_to(:user, :equals => @user) }
  it { should_not assign_to(:user, :posts) }</code></pre>

h2. filter_params

Macro that creates a test asserting that filter_parameter_logging is set for the specified keys.

Example:

  should_filter_params :password, :ssn
  it { should filter_params(:password, :ssn) }

h2. render_a_form

Macro that creates a test asserting that the rendered view contains a @<form>@ element.

Example:

  should_render_a_form
  it { should render_a_form }

h2. render_template

Macro that creates a test asserting that the controller rendered the given template.

Example:

  should_render_template :new
  it { should render_template(:new) }

h2. render_with_layout

Macro that creates a test asserting that the controller rendered with the given layout.

Example:

<pre><code>  should_render_with_layout 'special'
  should_render_with_layout :special

  it { should render_with_layout{'special'} }
  it { should render_with_layout(:special) }</code></pre>

h2. render_without_layout

Macro that creates a test asserting that the controller rendered without a layout. Same as @it { should render_with_layout(false) }@.

h2. respond_with

Macro that creates a test asserting that the controller responded with a ‘response’ status code.

Example:

  should_respond_with :success
  it { should respond_with(:success) }

h2. respond_with_content_type

Macro that creates a test asserting that the response content type was ‘content_type’.

Example:

<pre><code>  should_respond_with_content_type 'application/rss+xml'
  should_respond_with_content_type :rss
  should_respond_with_content_type /rss/

  it { should respond_with_content_type('application/rss+xml') }
  it { should respond_with_content_type(:rss) }
  it { should respond_with_content_type(/rss/) }</code></pre>

h2. set_session

Macro that creates a test asserting that a value returned from the session is correct. You can given a string to compare to or a proc which will be evaluated.

Example:

  should_set_session(:user_id, proc { @user.id })
  should_set_session(:user_id){ @user.id }
  it { should set_session(:message, 'Free stuff') }

h2. route

Macro that creates a routing test. It tries to use the given HTTP method on the given path, and asserts that it routes to the given options.

to_param is called on the options given.

Examples:

<pre><code>  should_route :get, "/posts", :controller => :posts, :action => :index
  should_route :get, "/posts/new", :controller => :posts, :action => :new
  should_route :post, "/posts", :controller => :posts, :action => :create
  should_route :get, "/posts/1", :controller => :posts, :action => :show, :id => 1

  it { should route(:get "/posts/1/edit", :controller => :posts, :action => :edit, :id => 1) }
  it { should route(:put, "/posts/1", :controller => :posts, :action => :update, :id => 1) }
  it { should route(:delete, "/posts/1", :controller => :posts, :action => :destroy, :id => 1) }
  it { should route(:get, "/users/1/posts/1",
    :controller => :posts, :action => :show, :id => 1, :user_id => 1) }</code></pre>

h2. set_the_flash_to

Macro that creates a test asserting that the flash contains the given value. val can be a String, a Regex, or nil (indicating that the flash should not be set).

Example:

<pre><code>  should_set_the_flash_to "Thank you for placing this order."
  should_set_the_flash_to /created/i
  should_not set_the_flash

  it { should set_the_flash_to("Thank you for placing this order.") }
  it { should set_the_flash_to(/created/i) }
  it { should_not set_the_flash }</code></pre>

h2. redirect_to

Macro that creates a test asserting that the controller returned a redirect to the given path. The given string is evaled to produce the resulting redirect path. All of the instance variables set by the controller are available to the evaled string.

Example:

<pre><code>  should_redirect_to "http://test.host/users/1/post/1"
  should_redirect_to { user_url(@user) }

  it { should redirect_to(user_post_url(@post.user, @post)) }
  it { should redirect_to(users_url) }</code></pre>

