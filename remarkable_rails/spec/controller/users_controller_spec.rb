require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  fixtures :all
  integrate_views

  describe "on DELETE destroy" do
    before(:each) do
      delete :destroy, :id => users(:first)
    end

    it { should redirect_to(users_url) }
    it { should redirect_to{ users_url } }
    it { should redirect_to('/users') }
    it { should redirect_to('http://test.host/users') }
    it { should redirect_to(:action => 'index') }
    it { should redirect_to(:controller => 'users') }
    it { should redirect_to(:controller => 'users', :action => 'index') }

    it { should_not redirect_to('/posts') }
    it { should_not redirect_to('http://test.host/posts') }
    it { should_not redirect_to(:action => 'show') }
    it { should_not redirect_to(:controller => 'posts') }
    it { should_not redirect_to(:controller => 'users', :action => 'show') }
  end

end

describe UsersController do
  fixtures :all
  integrate_views

  describe "on DELETE destroy" do
    before(:each) do
      delete :destroy, :id => users(:first)
    end

    should_redirect_to { users_url }
    should_redirect_to '/users'
    should_redirect_to 'http://test.host/users'
    should_redirect_to :action => 'index'
    should_redirect_to :controller => 'users'
    should_redirect_to :controller => 'users', :action => 'index'

    should_not_redirect_to '/posts'
    should_not_redirect_to 'http://test.host/posts'
    should_not_redirect_to :action => 'show'
    should_not_redirect_to :controller => 'posts'
    should_not_redirect_to :controller => 'users', :action => 'show'
  end

end
