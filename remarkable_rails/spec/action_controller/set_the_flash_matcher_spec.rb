require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'set_the_flash' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @matcher = set_the_flash(:notice).to('hi')
    end

    it 'should contain a description message' do
      @matcher = set_the_flash(:notice)
      @matcher.description.should == 'set the flash message notice'

      @matcher.to('hi')
      @matcher.description.should == 'set the flash message notice to "hi"'
    end

    it 'should set is_not_empty? message' do
      build_response
      @matcher = set_the_flash
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected any flash message to be set, got {}'
    end

    it 'should set contains_value? message' do
      build_response { flash[:notice] = 'bye' }
      @matcher = set_the_flash.to('hi')
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected any flash message to be set to "hi", got {:notice=>"bye"}'
    end

    it 'should set assigned_value? message' do
      build_response
      @matcher = set_the_flash(:notice)
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected flash message notice to be set, got {}'
    end

    it 'should set is_equal_value? message' do
      build_response { flash[:notice] = 'bye' }
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected flash message notice to be set to "hi", got {:notice=>"bye"}'
    end
  end

  describe 'matcher' do
    before(:each) { build_response { flash[:notice] = 'jose' } }

    it { should set_the_flash }
    it { should set_the_flash.to('jose') }
    it { should set_the_flash.to(/jose/) }
    it { should set_the_flash(:notice) }
    it { should set_the_flash(:notice).to('jose') }
    it { should set_the_flash(:notice).to(/jose/) }

    it { should_not set_the_flash.to('joseph') }
    it { should_not set_the_flash.to(/joseph/) }
    it { should_not set_the_flash(:error) }
    it { should_not set_the_flash(:notice).to('joseph') }
    it { should_not set_the_flash(:notice).to(/joseph/) }

    it { should set_the_flash{ 'jose' } }
    it { should set_the_flash{ /jose/ } }
    it { should set_the_flash(:notice){ 'jose' } }
    it { should set_the_flash(:notice){ /jose/ } }
    it { should set_the_flash(:notice, :to => proc{ 'jose' }) }
    it { should set_the_flash(:notice, :to => proc{ /jose/ }) }

    it { should_not set_the_flash(:notice).to(nil) }
    it { should_not set_the_flash(:notice){ 'joseph' } }
    it { should_not set_the_flash(:notice){ /joseph/ } }
    it { should_not set_the_flash(:notice, :to => proc{ 'joseph' }) }
    it { should_not set_the_flash(:notice, :to => proc{ /joseph/ }) }
  end

  describe 'macro' do
    before(:each) { build_response { flash[:notice] = 'jose' } }

    should_set_the_flash
    should_set_the_flash :to => 'jose'
    should_set_the_flash :to => /jose/
    should_set_the_flash :notice
    should_set_the_flash :notice, :to => 'jose'
    should_set_the_flash :notice, :to => /jose/

    should_not_set_the_flash :to => 'joseph'
    should_not_set_the_flash :to => /joseph/
    should_not_set_the_flash :error
    should_not_set_the_flash :notice, :to => 'joseph'
    should_not_set_the_flash :notice, :to => /joseph/

    should_set_the_flash(:notice){ 'jose' }
    should_set_the_flash(:notice){ /jose/ }
    should_set_the_flash :notice, :to => proc{ 'jose' }
    should_set_the_flash :notice, :to => proc{ /jose/ }

    should_set_the_flash :notice do |m|
      m.to = /jose/
    end

    should_not_set_the_flash :notice, :to => nil
    should_not_set_the_flash(:notice){ 'joseph' }
    should_not_set_the_flash(:notice){ /joseph/ }
    should_not_set_the_flash :notice, :to => proc{ 'joseph' }
    should_not_set_the_flash :notice, :to => proc{ /joseph/ }
  end

  describe 'with no parameter' do
    before(:each) { build_response }

    should_not_set_the_flash
    it { should_not set_the_flash }
  end

  generate_macro_stubs_specs_for(:set_the_flash)
end
