require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'validate_length_of' do

  before(:each) do
    @matcher = Remarkable::ActiveRecord::Matchers::ValidateLengthOfMatcher.new(:size).spec(self)
  end

  it 'should have a description' do
    @matcher.within(2..3)
    @matcher.description.should == 'ensure size length is within 2..3'

    @matcher.within(nil).in(2..3)
    @matcher.description.should == 'ensure size length is within 2..3'

    @matcher.in(nil).is(2)
    @matcher.description.should == 'ensure size length is 2'

    @matcher.is(nil).maximum(3)
    @matcher.description.should == 'ensure size length is maximum 3'

    @matcher.maximum(nil).minimum(2)
    @matcher.description.should == 'ensure size length is minimum 2'

    @matcher.allow_nil(false)
    @matcher.description.should == 'ensure size length is minimum 2 and not allow nil values'

    @matcher.allow_blank
    @matcher.description.should == 'ensure size length is minimum 2, not allow nil values, and allow blank values'
  end

  it 'should have an expectation message' do
    @matcher.matches?(Product.new)
    @matcher.expectation.should == 'Product ensures length of size'
  end

  it 'should set less than min length missing message' do
    @matcher.within(4..5).matches?(Product.new(:tangible => false))
    @matcher.instance_variable_get('@missing').should == 'allow size to be less than 4'
  end

  it 'should set exactly min length missing message' do
    @matcher.should_receive(:less_than_min_length?).and_return(true)
    @matcher.within(2..5).matches?(Product.new(:tangible => false))
    @matcher.instance_variable_get('@missing').should == 'not allow size to be 2'
  end

  it 'should set more than max length missing message' do
    @matcher.within(3..4).matches?(Product.new(:tangible => false))
    @matcher.instance_variable_get('@missing').should == 'allow size to be more than 4'
  end

  it 'should set exactly max length missing message' do
    @matcher.should_receive(:more_than_max_length?).and_return(true)
    @matcher.within(3..6).matches?(Product.new(:tangible => false))
    @matcher.instance_variable_get('@missing').should == 'not allow size to be 6'
  end

  it 'should set allow_blank missing message' do
    @matcher.within(3..5).allow_blank(false).matches?(Product.new(:tangible => false))
    @matcher.instance_variable_get('@missing').should == 'allow blank values for size'
  end

end
