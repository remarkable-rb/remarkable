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
    it 'should contain a description' do
      matcher = validate_numericality_of(:age)
      matcher.description.should == 'ensure numericality of age'

      matcher.allow_nil(false)
      matcher.description.should == 'ensure numericality of age not allowing nil values'

      matcher.allow_blank
      matcher.description.should == 'ensure numericality of age not allowing nil values and allowing blank values'

      matcher = validate_numericality_of(:age, :only_integer => true)
      matcher.description.should == 'ensure numericality of age allowing only integer values'

      matcher = validate_numericality_of(:age, :even => true)
      matcher.description.should == 'ensure numericality of age allowing only even values'

      matcher = validate_numericality_of(:age, :odd => true)
      matcher.description.should == 'ensure numericality of age allowing only odd values'

      matcher = validate_numericality_of(:age, :equal_to => 10)
      matcher.description.should == 'ensure numericality of age is equal to 10'

      matcher = validate_numericality_of(:age, :less_than_or_equal_to => 10)
      matcher.description.should == 'ensure numericality of age is less than or equal to 10'

      matcher = validate_numericality_of(:age, :greater_than_or_equal_to => 10)
      matcher.description.should == 'ensure numericality of age is greater than or equal to 10'

      matcher = validate_numericality_of(:age, :less_than => 10)
      matcher.description.should == 'ensure numericality of age is less than 10'

      matcher = validate_numericality_of(:age, :greater_than => 10)
      matcher.description.should == 'ensure numericality of age is greater than 10'

      matcher = validate_numericality_of(:age, :greater_than => 10, :less_than => 20)
      matcher.description.should == 'ensure numericality of age is greater than 10 and is less than 20'
    end

    # To test missing messages, we need expectations in assertions methods that
    # should return false.
    it 'should set only_numeric_values? message' do
      @matcher.should_receive(:only_numeric_values?).and_return(false)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow only numeric values for price'
      @matcher.negative_failure_message.should == 'Did not expect Product to allow only numeric values for price'
    end

    it 'should set only_integer_values? message' do
      @matcher.should_receive(:only_integer?).and_return([false, { :not => '' }])
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow only integer values for price'
    end

    it 'should set only_odd_values? message' do
      @matcher.should_receive(:only_odd?).and_return(false)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow only odd values for price'
    end

    it 'should set only_even_values? message' do
      @matcher.should_receive(:only_even?).and_return(false)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow only even values for price'
    end

    it 'should set equals_to? message' do
      @matcher.should_receive(:equals_to?).and_return([false, { :count => 10 }])
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to be valid only when price is equal to 10'
    end

    it 'should set less_than_minimum? message' do
      @matcher.should_receive(:less_than_minimum?).and_return([false, { :count => 10 }])
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to be invalid when price is less than 10'
    end

    it 'should set more_than_maximum? message' do
      @matcher.should_receive(:more_than_maximum?).and_return([false, { :count => 10 }])
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to be invalid when price is greater than 10'
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

    describe "with several options" do
      it { should define_and_validate(:less_than => 100, :greater_than => 10).less_than(100).greater_than(10) }
      it { should define_and_validate(:less_than => 100, :message => 'not valid').less_than(100).message('not valid') }
      it { should define_and_validate(:less_than_or_equal_to => 100, :greater_than => 1).less_than_or_equal_to(100).greater_than(1) }
    end

    # A macro to spec messages
    create_message_specs(self)

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
