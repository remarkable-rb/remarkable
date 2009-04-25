require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'assign_to' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @matcher = assign_to(:user).with('jose').with_kind_of(String)
    end

    it 'should contain a description message' do
      @matcher = assign_to(:user)
      @matcher.description.should == 'assign user'

      @matcher.with_kind_of(String)
      @matcher.description.should == 'assign user with kind of String'
    end

    it 'should set assigned_value? message' do
      build_response
      @matcher = assign_to(:user)
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected action to assign user, got no assignment'
    end

    it 'should set is_kind_of? message' do
      build_response { @user = 1 }
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected assign user to be kind of String, got a Fixnum'
    end

    it 'should set is_equal_value? message' do
      build_response { @user = 'joseph' }
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected assign user to be equal to "jose", got "joseph"'
    end
  end

  describe 'matcher' do
    before(:each) do
      build_response {
        @user  = 'jose'
        @true  = true
        @false = false
        @nil   = nil
      }
    end

    it { should assign_to(:user) }
    it { should assign_to(:user).with('jose') }
    it { should assign_to(:user).with_kind_of(String) }

    it { should_not assign_to(:post) }
    it { should_not assign_to(:user).with('joseph') }
    it { should_not assign_to(:user).with_kind_of(Fixnum) }

    it { should assign_to(:user){ 'jose' } }
    it { should assign_to(:user, :with => proc{ 'jose' }) }

    it { should_not assign_to(:user).with(nil) }
    it { should_not assign_to(:user){ 'joseph' } }
    it { should_not assign_to(:user, :with => proc{ 'joseph' }) }

    it { should assign_to(:true) }
    it { should assign_to(:true).with(true) }
    it { should_not assign_to(:true).with(false) }

    it { should assign_to(:false) }
    it { should assign_to(:false).with(false) }
    it { should_not assign_to(:false).with(true) }

    it { should assign_to(:nil) }
    it { should assign_to(:nil).with(nil) }
    it { should_not assign_to(:nil).with(true) }
  end

  describe 'macro' do
    before(:each) do
      build_response {
        @user  = 'jose'
        @true  = true
        @false = false
        @nil   = nil
      }
    end

    should_assign_to :user
    should_assign_to :user, :with => 'jose'
    should_assign_to :user, :with_kind_of => String

    should_assign_to :user do |m|
      m.with { 'jose' }
      m.with_kind_of String
    end

    should_not_assign_to :post
    should_not_assign_to :user, :with => 'joseph'
    should_not_assign_to :user, :with_kind_of => Fixnum

    should_assign_to(:user){ 'jose' }
    should_assign_to :user, :with => proc{ 'jose' }

    should_not_assign_to :user, :with => nil
    should_not_assign_to(:user){ 'joseph' }
    should_not_assign_to :user, :with => proc{ 'joseph' }

    should_assign_to :true
    should_assign_to :true, :with => true
    should_not_assign_to :true, :with => false

    should_assign_to :false
    should_assign_to :false, :with => false
    should_not_assign_to :false, :with => true

    should_assign_to :nil
    should_assign_to :nil, :with => nil
    should_not_assign_to :nil, :with => true
  end

  describe 'macro stubs' do
    before(:each) do
      @controller = TasksController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end

    expects :new, :on => String, :with => 'ola', :returns => 'ola'
    get :new

    it 'should run expectations by default' do
      String.should_receive(:should_receive).with(:new).and_return(@mock=mock('chain'))
      @mock.should_receive(:with).with('ola').and_return(@mock)
      @mock.should_receive(:exactly).with(1).and_return(@mock)
      @mock.should_receive(:times).and_return(@mock)
      @mock.should_receive(:and_return).with('ola').and_return('ola')

      assign_to(:user).matches?(@controller)
    end

    it 'should run stubs' do
      String.should_receive(:stub!).with(:new).and_return(@mock=mock('chain'))
      @mock.should_receive(:and_return).with('ola').and_return('ola')

      assign_to(:user, :with_stubs => true).matches?(@controller)
    end

  end
end
