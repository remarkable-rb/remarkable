require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'validate_acceptance_of' do
  include ModelBuilder

  # Defines a model, create a validation and returns a raw matcher
  def define_and_validate(options={})
    @model = define_model :user, :eula => :string, :terms => :string, :name => :string do
      validates_acceptance_of :eula, :terms, options
    end

    validate_acceptance_of(:eula, :terms)
  end

  describe 'messages' do
    before(:each){ @matcher = define_and_validate }

    it 'should contain a description' do
      @matcher.description.should == 'require eula and terms to be accepted'

      @matcher.accept('true')
      @matcher.description.should == 'require eula and terms to be accepted with value "true"'

      @matcher.allow_nil
      @matcher.description.should == 'require eula and terms to be accepted with value "true" and allowing nil values'
    end

    it 'should set requires_acceptance? message' do
      @matcher = validate_acceptance_of(:name)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected User to be invalid if name is not accepted'
    end

    it 'should set accept_is_valid? message' do
      @matcher.accept('accept_value').matches?(@model)
      @matcher.failure_message.should == 'Expected User to be valid when eula is accepted with value "accept_value"'
    end

  end

  describe 'matchers' do

    describe 'without options' do
      before(:each){ define_and_validate }

      it { should validate_acceptance_of(:eula) }
      it { should validate_acceptance_of(:eula, :terms) }
      it { should_not validate_acceptance_of(:eula, :name) }
    end

    describe 'with accept as option' do
      it { should define_and_validate(:accept => 'accept_value').accept('accept_value') }
      it { should_not define_and_validate(:accept => 'another_value').accept('a_value') }
    end

    create_message_specs(self)
    create_optional_boolean_specs(:allow_nil, self)
  end

  describe 'macros' do
    before(:each){ define_and_validate }

    should_validate_acceptance_of :eula
    should_validate_acceptance_of :eula, :terms
    should_not_validate_acceptance_of :eula, :name
  end

end
