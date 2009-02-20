require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Remarkable::DSL::Matches do
  subject { [1, 2, 3] }

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

  it 'should provide default options' do
    matcher = Remarkable::Specs::Matchers::SingleContainMatcher.new(1, :args => true)
    matcher.instance_variable_get('@options').should == { :working => true, :args => true }
  end

  it 'should provide an after initialize hook' do
    matcher = Remarkable::Specs::Matchers::SingleContainMatcher.new(1)
    matcher.instance_variable_get('@after_initialize').should be_true
  end

  it 'should provide a before assert hook' do
    matcher = Remarkable::Specs::Matchers::SingleContainMatcher.new(1)
    [1, 2, 3].should matcher
    matcher.instance_variable_get('@before_assert').should be_true
  end
end
