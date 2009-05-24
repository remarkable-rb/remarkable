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
  
    it 'should contain a description' do
      @matcher.within(3..5)
      @matcher.description.should == 'ensure length of size is within 3..5 characters'

      @matcher.within(nil).in(3..5)
      @matcher.description.should == 'ensure length of size is within 3..5 characters'

      @matcher.in(nil).is(3)
      @matcher.description.should == 'ensure length of size is equal to 3 characters'

      @matcher.is(nil).maximum(5)
      @matcher.description.should == 'ensure length of size is maximum 5 characters'

      @matcher.maximum(nil).minimum(3)
      @matcher.description.should == 'ensure length of size is minimum 3 characters'

      @matcher.allow_nil(false)
      @matcher.description.should == 'ensure length of size is minimum 3 characters and not allowing nil values'

      @matcher.allow_blank
      @matcher.description.should == 'ensure length of size is minimum 3 characters, not allowing nil values, and allowing blank values'
    end

    it 'should set less_than_min_length? message' do
      @matcher.within(4..5).matches?(@model)
      @matcher.failure_message.should == 'Expected Product to be invalid when size length is less than 4 characters'
    end

    it 'should set exactly_min_length? message' do
      @matcher.should_receive(:less_than_min_length?).and_return(true)
      @matcher.within(2..5).matches?(@model)
      @matcher.failure_message.should == 'Expected Product to be valid when size length is 2 characters'
    end

    it 'should set more_than_max_length? message' do
      @matcher.within(3..4).matches?(@model)
      @matcher.failure_message.should == 'Expected Product to be invalid when size length is more than 4 characters'
    end

    it 'should set exactly_max_length? message' do
      @matcher.should_receive(:more_than_max_length?).and_return(true)
      @matcher.within(3..6).matches?(@model)
      @matcher.failure_message.should == 'Expected Product to be valid when size length is 6 characters'
    end

    it 'should set allow_blank? message' do
      @matcher.within(3..5).allow_blank.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow blank values for size'
    end

    it 'should set allow_nil? message' do
      @matcher.within(3..5).allow_nil.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow nil values for size'
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

      if RAILS_VERSION =~ /^2.3/
        it { should define_and_validate(:message => 'not valid').within(3..5).message('not valid') }
        it { should_not define_and_validate(:message => 'not valid').within(3..5).message('valid') }
      else
        it { should define_and_validate(:too_short => 'not valid', :too_long => 'not valid').within(3..5).message('not valid') }
        it { should_not define_and_validate(:too_short => 'not valid', :too_long => 'not valid').within(3..5).message('valid') }
      end

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

    describe "with with kind of" do
      def define_and_validate(options)
        define_model :variant, :product_id => :integer

        @model = define_model :product do
          has_many :variants
          validates_length_of :variants, options
        end

        validate_length_of(:variants)
      end

      it { should define_and_validate(:within => 3..6).within(3..6).with_kind_of(Variant) }
      it { should_not define_and_validate(:within => 2..6).within(3..6).with_kind_of(Variant) }
      it { should_not define_and_validate(:within => 3..7).within(3..6).with_kind_of(Variant) }

      it "should raise association type mismatch if with_kind_of does not match" do
        lambda {
          should_not define_and_validate(:within => 3..6).within(3..6).with_kind_of(Product)
        }.should raise_error(ActiveRecord::AssociationTypeMismatch)
      end
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

    should_validate_length_of :size do |m|
      m.in = 3..5
    end
  end
end
