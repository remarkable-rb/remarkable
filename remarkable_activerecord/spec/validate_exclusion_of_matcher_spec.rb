require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'validate_exclusion_of' do
  include ModelBuilder

  # Defines a model, create a validation and returns a raw matcher
  def define_and_validate(*values)
    options = values.extract_options!

    @model = define_model :product, :title => :string, :size => :string, :category => :string do
      validates_exclusion_of :title, :size, options
    end

    validate_exclusion_of(:title, :size, :in => values)
  end

  describe 'messages' do
    it 'should contain a description' do
      @matcher = define_and_validate('X', 'Y', 'Z', :in => ['X', 'Y', 'Z'])
      @matcher.description.should == 'validate exclusion of X, Y, and Z in title and size'
    end

    it 'should set is_valid? missing message' do
      @matcher = define_and_validate('X', 'Y', 'Z', :in => ['X', 'Z'])
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to validate exclusion of Y in title'
    end

    it 'should set allow_nil? missing message' do
      @matcher = define_and_validate('X', 'Y', 'Z', :in => ['X', 'Y', 'Z', nil])
      @matcher.allow_nil.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow nil values for title'
    end

    it 'should set allow_blank? missing message' do
      @matcher = define_and_validate('X', 'Y', 'Z', :in => ['X', 'Y', 'Z', ''])
      @matcher.allow_blank.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow blank values for title'
    end
  end

  describe 'matchers' do
    it { should define_and_validate('X', :in => ['X']) }
    it { should_not define_and_validate('X', 'Y', :in => ['X']) }

    it { should define_and_validate('X', :message => 'valid_message', :in => ['X']).message('valid_message') }

    create_optional_boolean_specs(:allow_nil, self, :in => ['X', nil])
    create_optional_boolean_specs(:allow_blank, self, :in => ['X', ''])
  end

  describe 'macros' do
    before(:each){ define_and_validate('X', :in => ['X']) }

    should_validate_exclusion_of :title, :in => ['X']
    should_validate_exclusion_of :title, :size, :in => ['X']
    should_not_validate_exclusion_of :title, :size, :in => ['Y']
  end
end

