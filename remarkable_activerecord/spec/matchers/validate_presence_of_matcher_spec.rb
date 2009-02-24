require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'validate_presence_of' do

  def create_matcher(*attr)
    Remarkable::ActiveRecord::Matchers::ValidatePresenceOfMatcher.new(*attr).spec(self)
  end

  before(:each) do
    @matcher = create_matcher(:title, :size)
  end

  it 'should have a description' do
    @matcher.description.should == 'require title and size to be set'
  end

  it 'should have an expectation message' do
    @matcher.matches?(Product.new)
    @matcher.expectation.should == 'Product requires size to be set'
  end

  it 'should have message as optional' do
    @matcher.respond_to? :message
  end

  it 'should set allow_nil missing message' do
    @matcher.matches?(Product.new)
    @matcher.instance_variable_get('@missing').should == 'allow nil values for size'
  end

end
