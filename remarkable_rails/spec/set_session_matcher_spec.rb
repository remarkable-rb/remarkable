require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'set_session', :type => :controller do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @matcher = set_session(:user).to(1)
    end

    it 'should contain a description message' do
      @matcher = set_session(:user)
      @matcher.description.should == 'set session variable user'

      @matcher.to(1)
      @matcher.description.should == 'set session variable user to 1'
    end

    it 'should set assigned_value? message' do
      build_response
      @matcher = set_session(:user)
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected session variable user to be set, but got {}'
    end

    it 'should set is_equal_value? message' do
      build_response { session[:user] = 2 }
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected session variable user to be set to 1, but got {:user=>2}'
    end
  end

  describe 'matcher' do
    before(:each) { build_response { session[:user] = 'jose' } }

    it { should set_session(:user) }
    it { should set_session(:user).to('jose') }

    it { should_not set_session(:post) }
    it { should_not set_session(:user).to('joseph') }

    it { should set_session(:post).to(nil) }
    it { should set_session(:user){ 'jose' } }
    it { should set_session(:user, :to => proc{ 'jose' }) }

    it { should_not set_session(:user).to(nil) }
    it { should_not set_session(:user){ 'joseph' } }
    it { should_not set_session(:user, :to => proc{ 'joseph' }) }
  end

  describe 'macro' do
    before(:each) { build_response { session[:user] = 'jose' } }

    should_set_session :user
    should_set_session :user, :to => 'jose'

    should_not_set_session :post
    should_not_set_session :user, :to => 'joseph'

    should_set_session :post, :to => nil
    should_set_session(:user){ 'jose' }
    should_set_session :user, :to => proc{ 'jose' }

    should_not_set_session :user, :to => nil
    should_not_set_session(:user){ 'joseph' }
    should_not_set_session :user, :to => proc{ 'joseph' }
  end

end
