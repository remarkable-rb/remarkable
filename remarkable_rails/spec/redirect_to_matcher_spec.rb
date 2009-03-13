require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'redirect_to', :type => :controller do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @matcher = redirect_to('http://test.host/posts')
    end

    it 'should contain a description message' do
      @matcher.description.should == 'redirect to "http://test.host/posts"'
    end

    it 'should contain an expectation message' do
      build_response { redirect_to 'http://test.host/posts' }

      @matcher.matches?(@controller)
      @matcher.expectation.should == 'redirect to "http://test.host/posts"'
    end

    it 'should set redirected? missing message' do
      build_response { render :nothing => true }
      @matcher.matches?(@controller)
      @matcher.instance_variable_get('@missing').should == 'got no redirect'
    end

    it 'should set url_match? missing message' do
      build_response { redirect_to 'http://test.host/users' }
      @matcher.matches?(@controller)
      @matcher.instance_variable_get('@missing').should == 'redirected to "http://test.host/users"'
    end
  end

#    it { should redirect_to(users_url) }
#    it { should redirect_to{ users_url } }
#    it { should redirect_to('/users') }
#    it { should redirect_to('http://test.host/users') }
#    it { should redirect_to(:action => 'index') }
#    it { should redirect_to(:controller => 'users') }
#    it { should redirect_to(:controller => 'users', :action => 'index') }

#    # For rspec-rails compatibility
#    it { response.should redirect_to(users_url) }
#    it { response.should redirect_to('/users') }
#    it { response.should redirect_to(:controller => 'users', :action => 'index') }

#    it { should_not redirect_to('/posts') }
#    it { should_not redirect_to('http://test.host/posts') }
#    it { should_not redirect_to(:action => 'show') }
#    it { should_not redirect_to(:controller => 'posts') }
#    it { should_not redirect_to(:controller => 'users', :action => 'show') }

#    # For rspec-rails compatibility
#    it { response.should_not redirect_to('/posts') }
#    it { response.should_not redirect_to(:controller => 'users', :action => 'show') }

end
