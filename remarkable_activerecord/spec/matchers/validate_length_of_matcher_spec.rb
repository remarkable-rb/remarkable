require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'validate_length_of' do

  def create_matcher(*attr)
    Remarkable::ActiveRecord::Matchers::ValidateLengthOfMatcher.new(*attr).spec(self)
  end

  before(:each) do
    @matcher = create_matcher(:size)
  end

  it 'should have a description' do
    @matcher.within(2..3)
    @matcher.description.should == 'ensure length of size and within 2..3 characters'

    @matcher.within(nil).in(2..3)
    @matcher.description.should == 'ensure length of size and within 2..3 characters'

    @matcher.in(nil).is(2)
    @matcher.description.should == 'ensure length of size and equals to 2 characters'

    @matcher.is(nil).maximum(3)
    @matcher.description.should == 'ensure length of size and maximum 3 characters'

    @matcher.maximum(nil).minimum(2)
    @matcher.description.should == 'ensure length of size and minimum 2 characters'

    @matcher.allow_nil(false)
    @matcher.description.should == 'ensure length of size, minimum 2 characters, and not allow nil values'

    @matcher.allow_blank
    @matcher.description.should == 'ensure length of size, minimum 2 characters, not allow nil values, and allow blank values'
  end

  it 'should have an expectation message' do
    @matcher.matches?(Product.new)
    @matcher.expectation.should == 'Product ensures length of size'
  end

  it 'should set less than min length missing message' do
    @matcher.within(4..5).matches?(Product.new(:tangible => false))
    @matcher.instance_variable_get('@missing').should == 'allow size to be less than 4 characters'
  end

  it 'should set exactly min length missing message' do
    @matcher.should_receive(:less_than_min_length?).and_return(true)
    @matcher.within(2..5).matches?(Product.new(:tangible => false))
    @matcher.instance_variable_get('@missing').should == 'not allow size to be 2 characters'
  end

  it 'should set more than max length missing message' do
    @matcher.within(3..4).matches?(Product.new(:tangible => false))
    @matcher.instance_variable_get('@missing').should == 'allow size to be more than 4 characters'
  end

  it 'should set exactly max length missing message' do
    @matcher.should_receive(:more_than_max_length?).and_return(true)
    @matcher.within(3..6).matches?(Product.new(:tangible => false))
    @matcher.instance_variable_get('@missing').should == 'not allow size to be 6 characters'
  end

  it 'should set allow_blank missing message' do
    @matcher.within(3..5).allow_blank(false).matches?(Product.new(:tangible => false))
    @matcher.instance_variable_get('@missing').should == 'allow blank values for size'
  end

end
