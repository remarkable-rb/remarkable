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

    it 'should set is_not_empty? message' do
      build_response
      @matcher = set_session
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected any session variable to be set, but got {}'
    end

    it 'should set contains_value? message' do
      build_response { session[:user] = 10 }
      @matcher = set_session.to(1)
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected any session variable to be set to 1, but got {:user=>10}'
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

    it { should set_session }
    it { should set_session.to('jose') }
    it { should set_session(:user) }
    it { should set_session(:user).to('jose') }

    it { should_not set_session.to('joseph') }
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

    should_set_session
    should_set_session :to => 'jose'
    should_set_session :user
    should_set_session :user, :to => 'jose'

    should_not_set_session :to => 'joseph'
    should_not_set_session :post
    should_not_set_session :user, :to => 'joseph'

    should_set_session :post, :to => nil
    should_set_session(:user){ 'jose' }
    should_set_session :user, :to => proc{ 'jose' }

    should_not_set_session :user, :to => nil
    should_not_set_session(:user){ 'joseph' }
    should_not_set_session :user, :to => proc{ 'joseph' }
  end

  describe 'with no parameter' do
    before(:each) { build_response }

    should_not_set_session
    it { should_not set_session }
  end

end
