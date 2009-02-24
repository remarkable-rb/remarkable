require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'validate_numericality_of' do

  def create_matcher(*attr)
    Remarkable::ActiveRecord::Matchers::ValidateNumericalityOfMatcher.new(*attr).spec(self)
  end

  before(:each) do
    @matcher = create_matcher(:price)
  end

  it 'should have a description' do
    matcher = create_matcher(:age)
    matcher.description.should == 'ensure numericality of age'

    matcher.allow_nil(false)
    matcher.description.should == 'ensure numericality of age and not allow nil values'

    matcher.allow_blank
    matcher.description.should == 'ensure numericality of age, not allow nil values, and allow blank values'

    matcher = create_matcher(:age, :only_integer => true)
    matcher.description.should == 'ensure numericality of age and allow only integer values'

    matcher = create_matcher(:age, :even => true)
    matcher.description.should == 'ensure numericality of age and allow only even values'

    matcher = create_matcher(:age, :odd => true)
    matcher.description.should == 'ensure numericality of age and allow only odd values'

    matcher = create_matcher(:age, :equal_to => 10)
    matcher.description.should == 'ensure numericality of age and equal to 10'

    matcher = create_matcher(:age, :less_than_or_equal_to => 10)
    matcher.description.should == 'ensure numericality of age and less than or equal to 10'

    matcher = create_matcher(:age, :greater_than_or_equal_to => 10)
    matcher.description.should == 'ensure numericality of age and greater than or equal to 10'

    matcher = create_matcher(:age, :less_than => 10)
    matcher.description.should == 'ensure numericality of age and less than 10'

    matcher = create_matcher(:age, :greater_than => 10)
    matcher.description.should == 'ensure numericality of age and greater than 10'
  end

  it 'should have an expectation message' do
    @matcher.matches?(Product.new)
    @matcher.expectation.should == 'Product ensures numericality of price'
  end

  it 'should set only numeric values message' do
    @matcher.should_receive(:only_numeric_values?).and_return(false)
    @matcher.matches?(Product.new)
    @matcher.instance_variable_get('@missing').should == 'allow non-numeric values for price'
  end

  it 'should set only integer values message' do
    @matcher.should_receive(:only_integer?).and_return([false, { :not => '' }])
    @matcher.matches?(Product.new)
    @matcher.instance_variable_get('@missing').should == 'allow non-integer values for price'
  end

  it 'should set only odd values message' do
    @matcher.should_receive(:only_odd?).and_return([false, { :not => '' }])
    @matcher.matches?(Product.new)
    @matcher.instance_variable_get('@missing').should == 'allow non-odd values for price'
  end

  it 'should set only even values message' do
    @matcher.should_receive(:only_even?).and_return([false, { :not => '' }])
    @matcher.matches?(Product.new)
    @matcher.instance_variable_get('@missing').should == 'allow non-even values for price'
  end

  it 'should set equal to message' do
    @matcher.should_receive(:equal_to?).and_return([false, { :count => 10 }])
    @matcher.matches?(Product.new)
    @matcher.instance_variable_get('@missing').should == 'not allow price to be equal to 10'
  end

  it 'should set less than minimum message' do
    @matcher.should_receive(:less_than_minimum?).and_return([false, { :count => 10 }])
    @matcher.matches?(Product.new)
    @matcher.instance_variable_get('@missing').should == 'allow price to be less than 10'
  end

  it 'should set more than maximum message' do
    @matcher.should_receive(:more_than_maximum?).and_return([false, { :count => 10 }])
    @matcher.matches?(Product.new)
    @matcher.instance_variable_get('@missing').should == 'allow price to be greater than 10'
  end

end
