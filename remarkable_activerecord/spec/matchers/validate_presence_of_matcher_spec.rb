require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'validate_presence_of' do

  before(:each) do
    @matcher = Remarkable::ActiveRecord::Matchers::ValidatePresenceOfMatcher.new(:title, :size)
  end

  it 'should have a description' do
    @matcher.description.should == 'require title and size to be set'
  end

  it 'should have an expectation message' do
    @matcher.matches?(Product.new)
    @matcher.expectation.should == 'Product could not be saved if size is not set'
  end

  it 'should have set allow_nil missing message' do
    @matcher.matches?(Product.new)
    @matcher.instance_variable_get('@missing').should == 'allow nil values for size'
  end

  it 'should have message as optional' do
    @matcher.respond_to? :message
  end

end
