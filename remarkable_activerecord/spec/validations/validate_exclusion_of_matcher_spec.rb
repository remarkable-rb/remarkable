require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'validate_exclusion_of' do
  include ModelBuilder

  # Defines a model, create a validation and returns a raw matcher
  def define_and_validate(options={})
    @model = define_model :product, :title => :string, :size => :string do
      validates_exclusion_of :title, :size, options
    end

    validate_exclusion_of(:title, :size)
  end

  describe 'messages' do

    it 'should contain a description' do
      @matcher = define_and_validate(:in => 2..10)
      @matcher.in(2..10)
      @matcher.description.should == 'ensure exclusion of title and size in 2..10'

      @matcher = validate_exclusion_of(:title, :size).in('X', 'Y', 'Z')
      @matcher.description.should == 'ensure exclusion of title and size in "X", "Y", and "Z"'
    end

    it 'should set is_invalid? message' do
      @matcher = define_and_validate(:in => 2..10)
      @matcher.in(1..10).matches?(@model)
      @matcher.failure_message.should == 'Expected Product to be invalid when title is set to 1'
    end

    it 'should set is_valid? message' do
      @matcher = define_and_validate(:in => 2..10)
      @matcher.in(3..10).matches?(@model)
      @matcher.failure_message.should == 'Expected Product to be valid when title is set to 2'
    end

    it 'should set allow_nil? message' do
      @matcher = define_and_validate(:in => [nil])
      @matcher.allow_nil.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow nil values for title'
    end

    it 'should set allow_blank? message' do
      @matcher = define_and_validate(:in => [''])
      @matcher.allow_blank.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow blank values for title'
    end
  end

  describe 'matchers' do    it { should define_and_validate(:in => ['X', 'Y', 'Z']).in('X', 'Y', 'Z') }
    it { should_not define_and_validate(:in => ['X', 'Y', 'Z']).in('X', 'Y') }
    it { should_not define_and_validate(:in => ['X', 'Y', 'Z']).in('A') }

    it { should define_and_validate(:in => 2..3).in(2..3) }
    it { should define_and_validate(:in => 2..20).in(2..20) }
    it { should_not define_and_validate(:in => 2..20).in(1..20) }
    it { should_not define_and_validate(:in => 2..20).in(3..20) }
    it { should_not define_and_validate(:in => 2..20).in(2..19) }
    it { should_not define_and_validate(:in => 2..20).in(2..21) }

    it { should define_and_validate(:in => ['X', 'Y', 'Z'], :message => 'not valid').in('X', 'Y', 'Z').message('not valid') }
    it { should_not define_and_validate(:in => ['X', 'Y', 'Z'], :message => 'not valid').in('X', 'Y', 'Z').message('valid') }
  end

  describe 'macros' do
    describe 'with array' do
      before(:each){ define_and_validate(:in => ['X', 'Y', 'Z']) }

      should_validate_exclusion_of :title, :in => ['X', 'Y', 'Z']
      should_validate_exclusion_of :title, :size, :in => ['X', 'Y', 'Z']
      should_not_validate_exclusion_of :title, :in => ['X', 'Y']
      should_not_validate_exclusion_of :title, :size, :in => ['A']
    end

    describe 'with range' do
      before(:each){ define_and_validate(:in => 2..20) }

      should_validate_exclusion_of :title, :in => 2..20
      should_not_validate_exclusion_of :title, :in => 1..20
      should_not_validate_exclusion_of :title, :in => 3..20
      should_not_validate_exclusion_of :title, :in => 2..19
      should_not_validate_exclusion_of :title, :in => 2..21
    end
  end
end

