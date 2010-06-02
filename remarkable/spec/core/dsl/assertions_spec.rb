require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Remarkable::DSL::Assertions do
  subject { [1, 2, 3] }

  before(:each) do
    @matcher = Remarkable::RSpec::Matchers::CollectionContainMatcher.new(1, 2, 3)
  end

  it 'should provide default structure for assertions' do
    should collection_contain(1)
    should collection_contain(1, 2)
    should collection_contain(1, 2, 3)

    should_not collection_contain(4)
    should_not collection_contain(1, 4)
  end

  it 'should provide default structure for single assertions' do
    should single_contain(1)
    should_not single_contain(4)
    nil.should_not single_contain(1)
  end

  it 'should provide collection in description' do
    @matcher.description.should == 'contain 1, 2, and 3'
  end

  it 'should provide value to expectation messages' do
    @matcher.matches?([4])
    @matcher.failure_message.should == 'Expected that 1 is included in [4]'
  end

  it 'should accept blocks as argument' do
    should_not single_contain(4)
    should single_contain(4){ self << 4 }
  end

  it 'should provide an interface for default_options hook' do
    matcher = Remarkable::RSpec::Matchers::CollectionContainMatcher.new(1, :args => true)
    matcher.instance_variable_get('@options').should == { :working => true, :args => true }
  end

  it 'should provide an interface for after_initialize hook' do
    matcher = Remarkable::RSpec::Matchers::CollectionContainMatcher.new(1)
    matcher.instance_variable_get('@after_initialize').should be_true
  end

  it 'should provide an interface for before_assert hook' do
    matcher = Remarkable::RSpec::Matchers::CollectionContainMatcher.new(1)
    [1, 2, 3].should matcher
    matcher.instance_variable_get('@before_assert').should be_true
  end
end
