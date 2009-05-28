require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Remarkable::Base do
  subject { [1, 2, 3] }

  it 'should provide default structure to matchers' do
    [1, 2, 3].should contain(1)
    [1, 2, 3].should contain(1, 2)
    [1, 2, 3].should contain(1, 2, 3)

    [1, 2, 3].should_not contain(4)
    [1, 2, 3].should_not contain(1, 4)
  end

  it 'should not change rspec matchers default behavior' do
    should include(3)
    [1, 2, 3].should include(3)

    1.should == 1
    true.should be_true
    false.should be_false
    proc{ 1 + '' }.should raise_error(TypeError)
  end

  it 'should store spec instance binding' do
    matcher = contain(1)
    should matcher
    matcher.instance_variable_get('@spec').class.ancestors.should include(Spec::Example::ExampleGroup)
  end

  it { should contain(1) }
  it { should_not contain(10) }

  class MatchersSandbox
    include Remarkable::Matchers
  end

  it 'should allow Macros and Matchers to be added to any class' do
    MatchersSandbox.new.should respond_to(:contain)
  end

  it 'should raise an error if include matchers is called without target and rspec is not loaded' do
    Remarkable.stub!(:rspec_defined?).and_return(false)
    lambda {
      Remarkable.include_matchers!(String)
    }.should raise_error(ArgumentError, "You haven't supplied the target to include_matchers! and RSpec is not loaded, so we cannot infer one.")
  end
end
