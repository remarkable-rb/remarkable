require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'validate_length_of' do
  include ModelBuilder

  # Defines a model, create a validation and returns a raw matcher
  def define_and_validate(options={})
    options = options.merge(:within => 3..5) if options.slice(:in, :within, :maximum, :minimum, :is).empty?

    @model = define_model :product, :size => :string, :category => :string do
      validates_length_of :size, options
    end

    validate_length_of(:size)
  end

  describe 'messages' do
    before(:each){ @matcher = define_and_validate }
  
    it 'should contain a description message' do
      @matcher.within(3..5)
      @matcher.description.should == 'ensure length of size and within 3..5 characters'

      @matcher.within(nil).in(3..5)
      @matcher.description.should == 'ensure length of size and within 3..5 characters'

      @matcher.in(nil).is(3)
      @matcher.description.should == 'ensure length of size and equals to 3 characters'

      @matcher.is(nil).maximum(5)
      @matcher.description.should == 'ensure length of size and maximum 5 characters'

      @matcher.maximum(nil).minimum(3)
      @matcher.description.should == 'ensure length of size and minimum 3 characters'

      @matcher.allow_nil(false)
      @matcher.description.should == 'ensure length of size, minimum 3 characters, and not allow nil values'

      @matcher.allow_blank
      @matcher.description.should == 'ensure length of size, minimum 3 characters, not allow nil values, and allow blank values'
    end

    it 'should contain an expectation message' do
      @matcher.matches?(@model)
      @matcher.expectation.should == 'Product ensures length of size'
    end

    it 'should set less_than_min_length missing message' do
      @matcher.within(4..5).matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'allow size to be less than 4 characters'
    end

    it 'should set exactly_min_length missing message' do
      @matcher.should_receive(:less_than_min_length?).and_return(true)
      @matcher.within(2..5).matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'not allow size to be 2 characters'
    end

    it 'should set more_than_max_length missing message' do
      @matcher.within(3..4).matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'allow size to be more than 4 characters'
    end

    it 'should set exactly_max_length missing message' do
      @matcher.should_receive(:more_than_max_length?).and_return(true)
      @matcher.within(3..6).matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'not allow size to be 6 characters'
    end

    it 'should set allow_blank missing message' do
      @matcher.should_receive(:allow_blank?).and_return([false, {:default => 'allow blank values for size'}])
      @matcher.within(3..5).matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'allow blank values for size'
    end

    it 'should set allow_nil missing message' do
      @matcher.should_receive(:allow_nil?).and_return([false, {:default => 'allow nil values for size'}])
      @matcher.within(3..5).matches?(@model)
      @matcher.instance_variable_get('@missing').should == 'allow nil values for size'
    end
  end

  describe 'matcher' do
    # Wrap specs without options. Usually a couple specs.
    describe 'without options' do
      before(:each){ define_and_validate }

      it { should validate_length_of(:size, :within => 3..5) }
      it { should_not validate_length_of(:category, :within => 3..5) }
    end

    describe "with message option" do
      it { should define_and_validate(:message => 'not valid').within(3..5).message('not valid') }
      it { should_not define_and_validate(:message => 'not valid').within(3..5).message('valid') }

      it { should define_and_validate(:is => 4, :message => 'not valid').is(4).message('not valid') }
      it { should_not define_and_validate(:is => 4, :message => 'not valid').is(4).message('valid') }
    end

    describe "with too_short option" do
      it { should define_and_validate(:too_short => 'not valid').within(3..5).too_short('not valid') }
      it { should_not define_and_validate(:too_short => 'not valid').within(3..5).too_short('valid') }
    end

    describe "with too_long option" do
      it { should define_and_validate(:too_long => 'not valid').within(3..5).too_long('not valid') }
      it { should_not define_and_validate(:too_long => 'not valid').within(3..5).too_long('valid') }
    end

    describe "with wrong_length option" do
      it { should define_and_validate(:is => 4, :wrong_length => 'not valid').is(4).wrong_length('not valid') }
      it { should_not define_and_validate(:is => 4, :wrong_length => 'not valid').is(4).wrong_length('valid') }
    end

    describe "with within option" do
      it { should define_and_validate(:within => 3..5).within(3..5)     }
      it { should_not define_and_validate(:within => 3..5).within(2..5) }
      it { should_not define_and_validate(:within => 3..5).within(4..5) }
      it { should_not define_and_validate(:within => 3..5).within(3..4) }
      it { should_not define_and_validate(:within => 3..5).within(3..6) }
    end

    describe "with in option" do
      it { should define_and_validate(:in => 3..5).within(3..5)     }
      it { should_not define_and_validate(:in => 3..5).within(2..5) }
      it { should_not define_and_validate(:in => 3..5).within(4..5) }
      it { should_not define_and_validate(:in => 3..5).within(3..4) }
      it { should_not define_and_validate(:in => 3..5).within(3..6) }
    end

    describe "with minimum option" do
      it { should define_and_validate(:minimum => 3).minimum(3)     }
      it { should_not define_and_validate(:minimum => 3).minimum(2) }
      it { should_not define_and_validate(:minimum => 3).minimum(4) }
    end

    describe "with maximum option" do
      it { should define_and_validate(:maximum => 3).maximum(3)     }
      it { should_not define_and_validate(:maximum => 3).maximum(2) }
      it { should_not define_and_validate(:maximum => 3).maximum(4) }
    end

    describe "with is option" do
      it { should define_and_validate(:is => 3).is(3)     }
      it { should_not define_and_validate(:is => 3).is(2) }
      it { should_not define_and_validate(:is => 3).is(4) }
    end

    # Those are macros to test optionals which accept only boolean values
    create_optional_boolean_specs(:allow_nil, self)
    create_optional_boolean_specs(:allow_blank, self)
  end

  # In macros we include just a few tests to assure that everything works properly
  describe 'macros' do
    before(:each) { define_and_validate }

    should_validate_length_of :size, :in => 3..5
    should_validate_length_of :size, :within => 3..5
    should_not_validate_length_of :size, :within => 2..5
    should_not_validate_length_of :size, :within => 4..5
    should_not_validate_length_of :size, :within => 3..4
    should_not_validate_length_of :size, :within => 3..6
    should_not_validate_length_of :category, :in => 3..5
  end
end
