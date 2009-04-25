require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'set_cookies' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @matcher = set_cookies(:user).to(1)
    end

    it 'should contain a description message' do
      @matcher = set_cookies(:user)
      @matcher.description.should == 'set cookies user'

      @matcher.to(1)
      @matcher.description.should == 'set cookies user to 1'
    end

    it 'should set is_not_empty? message' do
      build_response
      @matcher = set_cookies
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected any cookie to be set, got {}'
    end

    it 'should set assigned_value? message' do
      build_response
      @matcher = set_cookies(:user)
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected cookie user to be set, got {}'
    end

    if RAILS_VERSION =~ /^2.(1|2)/
      it 'should set contains_value? message' do
        build_response { cookies[:user] = 10 }
        @matcher = set_cookies.to(1)
        @matcher.matches?(@controller)
        @matcher.failure_message.should == 'Expected any cookie to be set to [1], got {:user=>[10]}'
      end

      it 'should set is_equal_value? message' do
        build_response { cookies[:user] = 2 }
        @matcher.matches?(@controller)
        @matcher.failure_message.should == 'Expected cookie user to be set to [1], got {:user=>[2]}'
      end
    else
      it 'should set contains_value? message' do
        build_response { cookies[:user] = 10 }
        @matcher = set_cookies.to(1)
        @matcher.matches?(@controller)
        @matcher.failure_message.should == 'Expected any cookie to be set to "1", got {:user=>"10"}'
      end

      it 'should set is_equal_value? message' do
        build_response { cookies[:user] = 2 }
        @matcher.matches?(@controller)
        @matcher.failure_message.should == 'Expected cookie user to be set to "1", got {:user=>"2"}'
      end
    end
  end

  describe 'matcher' do
    before(:each) do
     build_response {
        cookies[:user]    = 'jose'
        cookies[:true]    = true
        cookies[:false]   = false
        cookies[:nil]     = nil
        cookies[:array]   = [1,2]
        cookies[:date]    = Date.today
      }
    end

    it { should set_cookies }
    it { should set_cookies.to('jose') }
    it { should set_cookies(:user) }
    it { should set_cookies(:user).to('jose') }

    it { should_not set_cookies.to('joseph') }
    it { should_not set_cookies(:post) }
    it { should_not set_cookies(:user).to('joseph') }

    it { should set_cookies(:user){ 'jose' } }
    it { should set_cookies(:user, :to => proc{ 'jose' }) }

    it { should_not set_cookies(:user).to(nil) }
    it { should_not set_cookies(:user){ 'joseph' } }
    it { should_not set_cookies(:user, :to => proc{ 'joseph' }) }

    it { should set_cookies(:true) }
    it { should set_cookies(:true).to(true) }
    it { should_not set_cookies(:true).to(false) }

    it { should set_cookies(:false) }
    it { should set_cookies(:false).to(false) }
    it { should_not set_cookies(:false).to(true) }

    it { should set_cookies(:nil) }
    it { should set_cookies(:nil).to(nil) }
    it { should_not set_cookies(:nil).to(true) }

    it { should set_cookies(:array) }
    it { should set_cookies(:array).to([1,2]) }
    it { should_not set_cookies(:array).to([2,1]) }

    it { should set_cookies(:date) }
    it { should set_cookies(:date).to(Date.today) }
    it { should_not set_cookies(:date).to(Date.today + 1) }
  end

  describe 'macro' do
    before(:each) do
     build_response {
        cookies[:user]    = 'jose'
        cookies[:true]    = true
        cookies[:false]   = false
        cookies[:nil]     = nil
        cookies[:array]   = [1,2]
        cookies[:date]    = Date.today
      }
    end

    should_set_cookies
    should_set_cookies :to => 'jose'
    should_set_cookies :user
    should_set_cookies :user, :to => 'jose'

    should_not_set_cookies :to => 'joseph'
    should_not_set_cookies :post
    should_not_set_cookies :user, :to => 'joseph'

    should_set_cookies(:user){ 'jose' }
    should_set_cookies :user, :to => proc{ 'jose' }
    should_set_cookies :user do |m|
      m.to { 'jose' }
    end

    should_not_set_cookies :user, :to => nil
    should_not_set_cookies(:user){ 'joseph' }
    should_not_set_cookies :user, :to => proc{ 'joseph' }

    should_set_cookies :true
    should_set_cookies :true, :to => true
    should_not_set_cookies :true, :to => false

    should_set_cookies :false
    should_set_cookies :false, :to => false
    should_not_set_cookies :false, :to => true

    should_set_cookies :nil
    should_set_cookies :nil, :to => nil
    should_not_set_cookies :nil, :to => true

    should_set_cookies :array
    should_set_cookies :array, :to => [1,2]
    should_not_set_cookies :array, :to => [2,1]

    should_set_cookies :date
    should_set_cookies :date, :to => Date.today
    should_not_set_cookies :date, :to => (Date.today + 1)
  end

  describe 'with no parameter' do
    before(:each) { build_response }

    should_not_set_cookies
    it { should_not set_cookies }
  end

  generate_macro_stubs_specs_for(:set_cookies)
end
