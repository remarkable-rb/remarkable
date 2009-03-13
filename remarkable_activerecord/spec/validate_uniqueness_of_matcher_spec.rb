require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'validate_uniqueness_of' do
  include ModelBuilder

  # Defines a model, create a validation and returns a raw matcher
  def define_and_validate(options={})
    @model = define_model :user, :username => :string, :email => :integer, :access_code => :string do
      validates_uniqueness_of :username, options
    end

    # Create a model
    User.create(:username => 'jose')

    validate_uniqueness_of(:username)
  end

  describe 'messages' do
    before(:each){ @matcher = define_and_validate }

    it 'should contain a description' do
      @matcher.description.should == 'require unique values for username'

      @matcher.scope(:email)
      @matcher.description.should == 'require unique values for username scoped to [:email]'

      @matcher.scope(:email, :access_code)
      @matcher.description.should == 'require unique values for username scoped to [:email, :access_code]'

      @matcher.case_sensitive
      @matcher.description.should == 'require unique values for username scoped to [:email, :access_code] and case sensitive'

      @matcher.case_sensitive(false)
      @matcher.description.should == 'require unique values for username scoped to [:email, :access_code] and case insensitive'

      @matcher.allow_nil
      @matcher.description.should == 'require unique values for username scoped to [:email, :access_code], case insensitive, and allowing nil values'

      @matcher.allow_blank(false)
      @matcher.description.should == 'require unique values for username scoped to [:email, :access_code], case insensitive, allowing nil values, and not allowing blank values'
    end

    it 'should set respond_to_scope? message' do
      @matcher.scope(:title).matches?(@model)
      @matcher.failure_message.should == 'Expected User instance responds to title='
    end

    it 'should set is_unique? message' do
      @matcher = validate_uniqueness_of(:email)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected User to require unique values for email'
    end

    it 'should set case_sensitive? message' do
      @matcher.case_sensitive(false).matches?(@model)
      @matcher.failure_message.should == 'Expected User to not be case sensitive on username validation'
    end

    it 'should valid with new scope' do
      @matcher.scope(:email).matches?(@model)
      @matcher.failure_message.should == 'Expected User to be valid when username scope (email) change'
    end
  end

  describe 'matcher' do

    describe 'without options' do
      before(:each){ define_and_validate }

      it { should validate_uniqueness_of(:username) }
      it { should_not validate_uniqueness_of(:email) }
    end

    describe 'scoped to' do
      it { should define_and_validate(:scope => :email).scope(:email) }
      it { should define_and_validate(:scope => [:email, :access_code]).scope(:email, :access_code) }
      it { should_not define_and_validate(:scope => :email).scope(:title) }
      it { should_not define_and_validate(:scope => :email).scope(:access_code) }
    end

    # Those are macros to test optionals which accept only boolean values
    create_optional_boolean_specs(:allow_nil, self)
    create_optional_boolean_specs(:allow_blank, self)
    create_optional_boolean_specs(:case_sensitive, self)
  end

  describe 'errors' do
    it 'should raise an error if no object is found' do
      @matcher = define_and_validate
      User.destroy_all

      proc { @matcher.matches?(@model) }.should raise_error(ScriptError)
    end

    it 'should raise an error if no object with not nil attribute is found' do
      @matcher = define_and_validate.allow_nil
      User.destroy_all

      User.create(:username => nil)
      proc { @matcher.matches?(@model) }.should raise_error(ScriptError)

      User.create(:username => 'jose')
      proc { @matcher.matches?(@model) }.should_not raise_error(ScriptError)
    end

    it 'should raise an error if no object with not nil attribute is found' do
      @matcher = define_and_validate.allow_blank
      User.destroy_all

      User.create(:username => '')
      proc { @matcher.matches?(@model) }.should raise_error(ScriptError)

      User.create(:username => 'jose')
      proc { @matcher.matches?(@model) }.should_not raise_error(ScriptError)
    end

    it 'should raise an error if cannot find a new scope value' do
      @matcher = define_and_validate(:scope => :email).scope(:email)

      1000.upto(1100).each do |i|
        User.create!(:username => 'jose', :email => i)
      end
      proc { @matcher.matches?(@model) }.should raise_error(ScriptError)

      User.find_by_email('1050').destroy
      proc { @matcher.matches?(@model) }.should_not raise_error(ScriptError)
    end
  end

end
