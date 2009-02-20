require File.dirname(__FILE__) + '/spec_helper'

describe Remarkable::Base do

  before(:each) do
    @matcher = Remarkable::Specs::Matchers::ContainMatcher.new(1, 2, 3)
  end

  it 'should be set to negative' do
    @matcher.send(:positive?).should be_true
    @matcher.send(:negative?).should be_false

    @matcher.negative

    @matcher.send(:positive?).should be_false
    @matcher.send(:negative?).should be_true
  end

  it 'should store spec binding' do
    @matcher.spec(:binding)
    @matcher.instance_variable_get('@spec').should == :binding
  end

  it 'should provide default structure to matchers' do
    [1, 2, 3].should contain(1)
    [1, 2, 3].should contain(1, 2)
    [1, 2, 3].should contain(1, 2, 3)

    [1, 2, 3].should_not contain(4)
    [1, 2, 3].should_not contain(1, 4)
  end

  it { [1, 2, 3].should contain(1) }
  it { [1, 2, 3].should_not contain(10) }
end
