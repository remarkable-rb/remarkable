require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'redirect_to' do
  fixtures :all

  before(:each) do
    @matcher = Remarkable::ActionController::Matchers::RedirectToMatcher.new('http://test.host/posts')
    @matcher.spec(self)

    @controller = UsersController.new
    @response   = ActionController::TestResponse.new
    @request    = ActionController::TestRequest.new
  end

  it 'should have a description' do
    @matcher.description.should == 'redirect to "http://test.host/posts"'
  end

  it 'should have an expectation message' do
    @matcher.matches?(@controller)
    @matcher.expectation.should == 'redirect to "http://test.host/posts"'
  end

  it 'should set redirected missing message' do
    @matcher.matches?(@controller)
    @matcher.instance_variable_get('@missing').should == 'got no redirect'
  end

  it 'should set url match missing message' do
    delete :destroy, :id => users(:first)
    @matcher.matches?(@controller)
    @matcher.instance_variable_get('@missing').should == 'redirected to "http://test.host/users"'
  end

end
