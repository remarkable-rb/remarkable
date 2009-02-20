require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Remarkable::DSL::Assertions do
  subject { [1, 2, 3] }

  before(:each) do
    @matcher = Remarkable::Specs::Matchers::CollectionContainMatcher.new(1, 2, 3)
  end

  it 'should provide collection in description' do
    @matcher.description.should == 'contain 1, 2, and 3'
  end

  it 'should provide value in expectation' do
    @matcher.matches?([4])
    @matcher.expectation.should == '1 is included in [4]'
  end

  it 'should provide value to missing messages' do
    @matcher.matches?([4])
    @matcher.failure_message.should == 'Expected 1 is included in [4] (ERROR: 1 is not included in [4])'
  end

  it 'should accept blocks as argument' do
    should_not single_contain(4)
    should single_contain(4){ |array| array << 4 }
  end

  it 'should provide an interface for after_initialize hook' do
    matcher = Remarkable::Specs::Matchers::CollectionContainMatcher.new(1)
    matcher.instance_variable_get('@after_initialize').should be_true
  end

  it 'should provide an interface for before_assert hook' do
    matcher = Remarkable::Specs::Matchers::CollectionContainMatcher.new(1)
    [1, 2, 3].should matcher
    matcher.instance_variable_get('@before_assert').should be_true
  end

  it 'should provide an interface for default_options hook' do
    matcher = Remarkable::Specs::Matchers::CollectionContainMatcher.new(1, :args => true)
    matcher.instance_variable_get('@options').should == { :working => true, :args => true }
  end
end
