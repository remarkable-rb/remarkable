require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PostsController do
  fixtures :all

  # autodetects the :controller
  should_route     :get,    '/posts',         :controller => :posts, :action => :index
  should_not_route :get,    '/posts',         :controller => :posts, :action => :show
  # explicitly specify :controller
  should_route :post,   '/posts',             :controller => :posts, :action => :create
  # non-string parameter
  should_route :get,    '/posts/1',           :controller => :posts, :action => :show,    :id => 1
  # string-parameter
  should_route :put,    '/posts/1',           :controller => :posts, :action => :update,  :id => "1"
  should_route :delete, '/posts/1',           :controller => :posts, :action => :destroy, :id => 1
  should_route :get,    '/posts/new',         :controller => :posts, :action => :new

  # Test the nested routes
  should_route :get,    '/users/5/posts',     :controller => :posts, :action => :index,   :user_id => 5
  should_route :post,   '/users/5/posts',     :controller => :posts, :action => :create,  :user_id => 5
  should_route :get,    '/users/5/posts/1',   :controller => :posts, :action => :show,    :id => 1, :user_id => 5
  should_route :delete, '/users/5/posts/1',   :controller => :posts, :action => :destroy, :id => 1, :user_id => 5
  should_route :get,    '/users/5/posts/new', :controller => :posts, :action => :new,     :user_id => 5
  should_route :put,    '/users/5/posts/1',   :controller => :posts, :action => :update,  :id => 1, :user_id => 5

  describe "Logged in" do
    before do
      request.session[:logged_in] = true
    end

    describe "viewing posts for a user" do
      before do
        get :index, :user_id => users(:first)
      end
      should_respond_with 200
      should_assign_to :user, :class => User, :equals => 'users(:first)'
      should_not_assign_to :user, :class => User, :equals => 'users(:second)'

      should_not_assign_to :user, :class => Post
      should_not_assign_to :user, :equals => 'posts(:first)'
      it { lambda { should_assign_to(:user, :class => Post) }.should raise_error }
      it { lambda { should_assign_to(:user, :equals => 'posts(:first)') }.should raise_error }

      should_assign_to :posts
      should_not_assign_to :foo, :bar
    end

    describe "on POST to :create" do
      before do
        post :create, :post => { :title => "Title", :body => "Body" }, :user_id => users(:first)
        @post = Post.last
      end
      should_respond_with :redirect
      should_respond_with 302
      should_not_respond_with :success

      should_redirect_to "user_post_url(@post.user, @post)"
      should_not_redirect_to "user_url(@post.user)"
      should_set_the_flash_to /created/i
    end

    describe "viewing posts for a user with rss format" do
      before do
        get :index, :user_id => users(:first), :format => 'rss'
        @user = users(:first)
      end
      should_respond_with :success
      should_respond_with_content_type 'application/rss+xml'
      should_respond_with_content_type :rss
      should_respond_with_content_type /rss/

      should_return_from_session :special, "'$2 off your next purchase'"
      should_return_from_session :special_user_id, '@user.id'
      should_not_return_from_session(:monkey, "'fat'")

      should_assign_to :user, :posts
      should_not_assign_to :foo, :bar
    end

    describe "viewing a post on GET to #show" do
      before { get :show, :user_id => users(:first), :id => posts(:first) }

      should_render_with_layout 'wide'
      should_render_with_layout :wide
      should_not_render_with_layout 'other'

      should_not_respond_with_content_type :rss

      should_render_template :show
      should_not_render_template :new
    end

    describe "on GET to #new" do
      before { get :new, :user_id => users(:first) }
      should_render_without_layout
      should_not_set_the_flash
    end
  end

end

describe PostsController do
  fixtures :all

  # autodetects the :controller
  it { should     route(:get, '/posts',    :action => :index) }
  it { should_not route(:get, '/posts',    :action => :show) }
  # explicitly specify :controller
  it { should route(:post,   '/posts',     :controller => :posts, :action => :create) }
  # # non-string parameter
  it { should route(:get,    '/posts/1',   :action => :show, :id => 1) }
  # # string-parameter
  it { should route(:put,    '/posts/1',   :action => :update, :id => "1") }
  it { should route(:delete, '/posts/1',   :action => :destroy, :id => 1) }
  it { should route(:get,    '/posts/new', :action => :new) }

  # # Test the nested routes
  it { should route(:get,    '/users/5/posts',     :action => :index, :user_id => 5) }
  it { should route(:post,   '/users/5/posts',     :action => :create, :user_id => 5) }
  it { should route(:get,    '/users/5/posts/1',   :action => :show, :id => 1, :user_id => 5) }
  it { should route(:delete, '/users/5/posts/1',   :action => :destroy, :id => 1, :user_id => 5) }
  it { should route(:get,    '/users/5/posts/new', :action => :new, :user_id => 5) }
  it { should route(:put,    '/users/5/posts/1',   :action => :update, :id => 1, :user_id => 5) }

  describe "Logged in" do
    before do
      request.session[:logged_in] = true
    end

    describe "viewing posts for a user" do
      before do
        get :index, :user_id => users(:first)
      end
      it { should respond_with(200) }

      it { should assign_to(:some_text) }
      it { should assign_to(:some_text, :equals => "foo bar") }
      it { should_not assign_to(:some_text, :equals => "foo without bar") }
      it { should assign_to(:user, :class => User, :equals => 'users(:first)') }
      it { should assign_to(:user, :class => User, :equals => users(:first)) }
      it { should_not assign_to(:user, :class => User, :equals => 'users(:second)') }
      it { should_not assign_to(:user, :class => User, :equals => users(:second)) }
      it { should_not assign_to(:user, :class => Post) }
      it { should_not assign_to(:user, :equals => 'posts(:first)') }
      it { should assign_to(:posts) }
      it { should_not assign_to(:foo, :bar) }
    end

    describe "on POST to :create" do
      before(:each) do
        post :create, :post => { :title => "Title", :body => "Body" }, :user_id => users(:first)
        @post = Post.last
      end
      it { should respond_with(:redirect) }
      it { should respond_with(302) }
      it { should_not respond_with(:success) }

      it { should redirect_to(user_post_url(@post.user, @post)) }
      it { should_not redirect_to(user_url(@post.user)) }
      it { should set_the_flash_to(/created/i) }
      it { should_not set_the_flash_to(/foo/i) }
    end

    describe "viewing posts for a user with rss format" do
      before do
        get :index, :user_id => users(:first), :format => 'rss'
        @user = users(:first)
      end
      it { should respond_with(:success) }
      it { should respond_with_content_type('application/rss+xml') }
      it { should respond_with_content_type(:rss) }
      it { should respond_with_content_type(/rss/) }
      it { should return_from_session(:special, "'$2 off your next purchase'") }
      it { should return_from_session(:special_user_id, '@user.id') }
      it { should_not return_from_session(:monkey, "'fat'") }
      it { should assign_to(:user, :posts) }
      it { should_not assign_to(:foo, :bar) }
    end

    describe "viewing a post on GET to #show" do
      before { get :show, :user_id => users(:first), :id => posts(:first) }

      it { should render_with_layout('wide') }
      it { should render_with_layout(:wide) }
      it { should_not render_with_layout('other') }

      it { should_not respond_with_content_type(:rss) }
      it { should render_template(:show) }
      it { should_not render_template(:new) }
    end

    describe "on GET to #new" do
      before { get :new, :user_id => users(:first) }
      it { should render_without_layout }
      it { should_not set_the_flash }
    end
  end

end
