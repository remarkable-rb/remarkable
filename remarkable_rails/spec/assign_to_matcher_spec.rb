require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'assign_to', :type => :controller do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @matcher = assign_to(:user).with('jose').with_kind_of(String)
    end

    it 'should contain a description message' do
      @matcher = assign_to(:user)
      @matcher.description.should == 'assign user'

      @matcher.with(1..2)
      @matcher.description.should == 'assign user with 1..2'

      @matcher.with_kind_of(String)
      @matcher.description.should == 'assign user with 1..2 and with kind of String'
    end

    it 'should set assigned_value? message' do
      build_response { @user = nil }
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected action to assign user'
    end

    it 'should set is_kind_of? message' do
      @contrller = build_response { @user = 1 }
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected assign user to be kind of String, but got a Fixnum'
    end

    it 'should set is_equal_value? message' do
      @contrller = build_response { @user = 'joseph' }
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected assign user to be equal to "jose", but got "joseph"'
    end
  end

  describe 'matcher' do
    before(:each) { build_response { @user = 'jose' } }

    describe 'success' do

    end

    describe 'failure' do

    end
  end

end
