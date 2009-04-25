require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'set_session' do
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
      @matcher.failure_message.should == 'Expected any session variable to be set, got {}'
    end

    it 'should set contains_value? message' do
      build_response { session[:user] = 10 }
      @matcher = set_session.to(1)
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected any session variable to be set to 1, got {:user=>10}'
    end

    it 'should set assigned_value? message' do
      build_response
      @matcher = set_session(:user)
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected session variable user to be set, got {}'
    end

    it 'should set is_equal_value? message' do
      build_response { session[:user] = 2 }
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected session variable user to be set to 1, got {:user=>2}'
    end
  end

  describe 'matcher' do
    before(:each) do
     build_response {
        session[:user]    = 'jose'
        session[:true]    = true
        session[:false]   = false
        session[:nil]     = nil
        session[:array]   = [1,2]
        session[:date]    = Date.today
      }
    end

    it { should set_session }
    it { should set_session.to('jose') }
    it { should set_session(:user) }
    it { should set_session(:user).to('jose') }

    it { should_not set_session.to('joseph') }
    it { should_not set_session(:post) }
    it { should_not set_session(:user).to('joseph') }

    it { should set_session(:user){ 'jose' } }
    it { should set_session(:user, :to => proc{ 'jose' }) }

    it { should_not set_session(:user).to(nil) }
    it { should_not set_session(:user){ 'joseph' } }
    it { should_not set_session(:user, :to => proc{ 'joseph' }) }

    it { should set_session(:true) }
    it { should set_session(:true).to(true) }
    it { should_not set_session(:true).to(false) }

    it { should set_session(:false) }
    it { should set_session(:false).to(false) }
    it { should_not set_session(:false).to(true) }

    it { should set_session(:nil) }
    it { should set_session(:nil).to(nil) }
    it { should_not set_session(:nil).to(true) }

    it { should set_session(:array) }
    it { should set_session(:array).to([1,2]) }
    it { should_not set_session(:array).to([2,1]) }

    it { should set_session(:date) }
    it { should set_session(:date).to(Date.today) }
    it { should_not set_session(:date).to(Date.today + 1) }
  end

  describe 'macro' do
    before(:each) do
     build_response {
        session[:user]    = 'jose'
        session[:true]    = true
        session[:false]   = false
        session[:nil]     = nil
        session[:array]   = [1,2]
        session[:date]    = Date.today
      }
    end

    should_set_session
    should_set_session :to => 'jose'
    should_set_session :user
    should_set_session :user, :to => 'jose'

    should_not_set_session :to => 'joseph'
    should_not_set_session :post
    should_not_set_session :user, :to => 'joseph'

    should_set_session(:user){ 'jose' }
    should_set_session :user, :to => proc{ 'jose' }

    should_set_session :user do |m|
      m.to { 'jose' }
    end

    should_not_set_session :user, :to => nil
    should_not_set_session(:user){ 'joseph' }
    should_not_set_session :user, :to => proc{ 'joseph' }

    should_set_session :true
    should_set_session :true, :to => true
    should_not_set_session :true, :to => false

    should_set_session :false
    should_set_session :false, :to => false
    should_not_set_session :false, :to => true

    should_set_session :nil
    should_set_session :nil, :to => nil
    should_not_set_session :nil, :to => true

    should_set_session :array
    should_set_session :array, :to => [1,2]
    should_not_set_session :array, :to => [2,1]

    should_set_session :date
    should_set_session :date, :to => Date.today
    should_not_set_session :date, :to => (Date.today + 1)
  end

  describe 'with no parameter' do
    before(:each) { build_response }

    should_not_set_session
    it { should_not set_session }
  end

  generate_macro_stubs_specs_for(:set_session)
end
