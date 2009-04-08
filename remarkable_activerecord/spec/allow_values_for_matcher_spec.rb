require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'allow_values_for' do
  include ModelBuilder

  # Defines a model, create a validation and returns a raw matcher
  def define_and_validate(options={})
    @model = define_model :product, :title => :string, :category => :string do
      validates_format_of :title, options
    end

    allow_values_for(:title)
  end

  describe 'messages' do
    before(:each){ @matcher = define_and_validate(:with => /X|Y|Z/) }

    it 'should contain a description' do
      @matcher = allow_values_for(:title, "X", "Y", "Z")
      @matcher.description.should == 'allow "X", "Y", and "Z" as values for title'
    end

    it 'should set is_valid? message' do
      @matcher.in("A").matches?(@model)
      @matcher.failure_message.should == 'Expected Product to be valid when title is set to "A"'
    end

    it 'should set allow_nil? message' do
      @matcher.allow_nil.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow nil values for title'
    end

    it 'should set allow_blank? message' do
      @matcher.allow_blank.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow blank values for title'
    end
  end

  describe 'matchers' do
    it { should define_and_validate(:with => /X|Y|Z/).in('X', 'Y', 'Z') }
    it { should_not define_and_validate(:with => /X|Y|Z/).in('A') }

    it { should define_and_validate(:with => /X|Y|Z/, :message => 'valid').in('X', 'Y', 'Z').message('valid') }

    create_optional_boolean_specs(:allow_nil, self, :with => /X|Y|Z/)
    create_optional_boolean_specs(:allow_blank, self, :with => /X|Y|Z/)
  end

  describe 'macros' do
    before(:each){ define_and_validate(:with => /X|Y|Z/) }

    should_allow_values_for :title, 'X'
    should_not_allow_values_for :title, 'A'
  end
end

