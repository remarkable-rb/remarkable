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

    it 'should set responds_to_scope? message' do
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

    create_message_specs(self)

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

    it 'should raise an error if no object with not blank attribute is found' do
      @matcher = define_and_validate.allow_blank
      User.destroy_all

      User.create(:username => '')
      proc { @matcher.matches?(@model) }.should raise_error(ScriptError)

      User.create(:username => 'jose')
      proc { @matcher.matches?(@model) }.should_not raise_error(ScriptError)
    end

    it 'should raise an error if @existing record is the same as @subject' do
      @matcher = define_and_validate
      proc { @matcher.matches?(User.first) }.should raise_error(ScriptError, /which is different from the subject record/)
    end

    it 'should raise an error if cannot find a new scope value' do
      @matcher = define_and_validate(:scope => :email).scope(:email)

      User.stub!(:find).and_return do |many, conditions|
        if many == :all
          1000.upto(1100).map{|i| User.new(:email => i) }
        else
          User.new(:username => 'jose')
        end
      end
      proc { @matcher.matches?(@model) }.should raise_error(ScriptError)

      User.stub!(:find).and_return do |many, conditions|
        if many == :all
          1000.upto(1099).map{|i| User.new(:email => i) }
        else
          User.new(:username => 'jose')
        end
      end
      proc { @matcher.matches?(@model) }.should_not raise_error(ScriptError)
    end

    describe 'when null or blank values are not allowed' do
      def define_and_validate(options={})
        @model = define_model :user, :username => [:string, {:null => false}] do
          validates_uniqueness_of :username, options
        end

        # Create a model
        User.create(:username => 'jose')
        validate_uniqueness_of(:username)
      end

      it { should define_and_validate }
      it { should define_and_validate(:allow_nil => false).allow_nil(false) }

      it 'should raise an error if allow nil is true but we cannot save nil values in the database'do
        proc { should define_and_validate.allow_nil }.should raise_error(ScriptError, /You declared that username accepts nil values in validate_uniqueness_of, but I cannot save nil values in the database, got/)
      end
    end
  end

  describe 'macros' do
    before(:each){ define_and_validate(:scope => :email) }

    should_validate_uniqueness_of :username
    should_validate_uniqueness_of :username, :scope => :email
    should_not_validate_uniqueness_of :email
    should_not_validate_uniqueness_of :username, :scope => :access_code
  end
end
