require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'validate_numericality_of' do
  include ModelBuilder

  # Defines a model, create a validation and returns a raw matcher
  def define_and_validate(options={})
    @model = define_model :product, :price => :integer, :size => :integer do
      validates_numericality_of :price, options
    end

    validate_numericality_of(:price)
  end

  describe 'messages' do
    before(:each){ @matcher = define_and_validate }

    # To tests descriptions, we don't need to use mocks neither stubs.
    # We just need to define a matcher.
    #
    it 'should contain a description message' do
      matcher = validate_numericality_of(:age)
      matcher.description.should == 'ensure numericality of age'

      matcher.allow_nil(false)
      matcher.description.should == 'ensure numericality of age and not allow nil values'

      matcher.allow_blank
      matcher.description.should == 'ensure numericality of age, not allow nil values, and allow blank values'

      matcher = validate_numericality_of(:age, :only_integer => true)
      matcher.description.should == 'ensure numericality of age and allow only integer values'

      matcher = validate_numericality_of(:age, :even => true)
      matcher.description.should == 'ensure numericality of age and allow only even values'

      matcher = validate_numericality_of(:age, :odd => true)
      matcher.description.should == 'ensure numericality of age and allow only odd values'

      matcher = validate_numericality_of(:age, :equal_to => 10)
      matcher.description.should == 'ensure numericality of age and equal to 10'

      matcher = validate_numericality_of(:age, :less_than_or_equal_to => 10)
      matcher.description.should == 'ensure numericality of age and less than or equal to 10'

      matcher = validate_numericality_of(:age, :greater_than_or_equal_to => 10)
      matcher.description.should == 'ensure numericality of age and greater than or equal to 10'

      matcher = validate_numericality_of(:age, :less_than => 10)
      matcher.description.should == 'ensure numericality of age and less than 10'

      matcher = validate_numericality_of(:age, :greater_than => 10)
      matcher.description.should == 'ensure numericality of age and greater than 10'
    end

    # Expectations and missing messages requires matches? to be called with
    # the subject to be validated.
    it 'should contain an expectation message' do
      @matcher.matches?(@model)
      @matcher.expectation.should == 'Product ensures numericality of price'
    end

    # To test missing messages, we need expectations in assertions methods that
    # should return false.
    it 'should set only numeric values message' do
      @matcher.should_receive(:only_numeric_values?).and_return(false)
      @matcher.matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'allow non-numeric values for price'
    end

    it 'should set only integer values message' do
      @matcher.should_receive(:only_integer?).and_return([false, { :not => '' }])
      @matcher.matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'allow non-integer values for price'
    end

    it 'should set only odd values message' do
      @matcher.should_receive(:only_odd?).and_return([false, { :not => '' }])
      @matcher.matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'allow non-odd values for price'
    end

    it 'should set only even values message' do
      @matcher.should_receive(:only_even?).and_return([false, { :not => '' }])
      @matcher.matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'allow non-even values for price'
    end

    it 'should set equal to message' do
      @matcher.should_receive(:equal_to?).and_return([false, { :count => 10 }])
      @matcher.matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'not allow price to be equal to 10'
    end

    it 'should set less than minimum message' do
      @matcher.should_receive(:less_than_minimum?).and_return([false, { :count => 10 }])
      @matcher.matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'allow price to be less than 10'
    end

    it 'should set more than maximum message' do
      @matcher.should_receive(:more_than_maximum?).and_return([false, { :count => 10 }])
      @matcher.matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'allow price to be greater than 10'
    end
  end

  describe 'matcher' do
    # Wrap specs without options. Usually a couple specs.
    describe 'without options' do
      before(:each){ define_and_validate }

      it { should validate_numericality_of(:price) }
      it { should_not validate_numericality_of(:size) }
    end

    # Wrap each option inside a describe group.
    describe 'with equal_to option' do
      it { should define_and_validate(:equal_to => 100).equal_to(100) }
      it { should_not define_and_validate(:equal_to => 100).equal_to(99) }
      it { should_not define_and_validate(:equal_to => 100).equal_to(101) }
    end

    describe 'with less_than option' do
      it { should define_and_validate(:less_than => 100).less_than(100) }
      it { should_not define_and_validate(:less_than => 100).less_than(99) }
      it { should_not define_and_validate(:less_than => 100).less_than(101) }
    end

    describe 'with greater_than option' do
      it { should define_and_validate(:greater_than => 100).greater_than(100) }
      it { should_not define_and_validate(:greater_than => 100).greater_than(99) }
      it { should_not define_and_validate(:greater_than => 100).greater_than(101) }
    end

    describe 'with less_than_or_equal_to option' do
      it { should define_and_validate(:less_than_or_equal_to => 100).less_than_or_equal_to(100) }
      it { should_not define_and_validate(:less_than_or_equal_to => 100).less_than_or_equal_to(99) }
      it { should_not define_and_validate(:less_than_or_equal_to => 100).less_than_or_equal_to(101) }
    end

    describe 'with greater_than_or_equal_to option' do
      it { should define_and_validate(:greater_than_or_equal_to => 100).greater_than_or_equal_to(100) }
      it { should_not define_and_validate(:greater_than_or_equal_to => 100).greater_than_or_equal_to(99) }
      it { should_not define_and_validate(:greater_than_or_equal_to => 100).greater_than_or_equal_to(101) }
    end

    describe "with even option" do
      it { should define_and_validate(:even => true).even }
      it { should_not define_and_validate.even(true)      }
    end

    describe "with odd option" do
      it { should define_and_validate(:odd => true).odd }
      it { should_not define_and_validate.odd(true)     }
    end

    describe "with message option" do
      it { should define_and_validate(:message => 'not valid').message('not valid') }
      it { should_not define_and_validate(:message => 'not valid').message('valid') }
    end

    describe "with several options" do
      it { should define_and_validate(:less_than => 100, :greater_than => 10).less_than(100).greater_than(10) }
      it { should define_and_validate(:less_than => 100, :message => 'not valid').less_than(100).message('not valid') }
      it { should define_and_validate(:less_than_or_equal_to => 100, :greater_than => 1).less_than_or_equal_to(100).greater_than(1) }
    end

    # Those are macros to test optionals which accept only boolean values
    create_optional_boolean_specs(:allow_nil, self)
    create_optional_boolean_specs(:allow_blank, self)
    create_optional_boolean_specs(:only_integer, self)
  end

  # In macros we include just a few tests to assure that everything works properly
  describe 'macros' do
    before(:each) { define_and_validate(:less_than => 100000, :greater_than => 9999) }

    should_validate_numericality_of :price
    should_validate_numericality_of :price, :less_than => 100000
    should_validate_numericality_of :price, :greater_than => 9999
    should_validate_numericality_of :price, :less_than => 100000, :greater_than => 999
    should_not_validate_numericality_of :size
    should_not_validate_numericality_of :price, :less_than => 55555
    should_not_validate_numericality_of :price, :greater_than => 55555
  end
end
