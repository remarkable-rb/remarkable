require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'filter_params' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @controller = define_controller :Posts do
        filter_parameter_logging :password
      end.new

      @matcher = filter_params(:user)
    end

    it 'should contain a description message' do
      @matcher.description.should == 'filter user parameters from log'
    end

    it 'should set respond_to_filter_params? message' do
      @controller = define_controller(:Comments).new
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected controller to respond to filter_parameters (controller is not filtering any parameter)'
    end

    it 'should set is_filtered? message' do
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected user to be filtered, got no filtering'
    end
  end

  describe 'filtering parameter' do
    before(:each) do 
      @controller = define_controller :Comments do
        filter_parameter_logging :password
      end.new

      self.class.subject { @controller }
    end

    should_filter_params
    should_filter_params(:password)
    should_not_filter_params(:user)

    it { should filter_params }
    it { should filter_params(:password) }
    it { should_not filter_params(:user) }
  end

  describe 'not filtering any parameter' do
    before(:each) do 
      @controller = define_controller(:Comments).new
      self.class.subject { @controller }
    end

    should_not_filter_params
    should_not_filter_params(:password)
    should_not_filter_params(:user)

    it { should_not filter_params }
    it { should_not filter_params(:user) }
    it { should_not filter_params(:password) }
  end

end
