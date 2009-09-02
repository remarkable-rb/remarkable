require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'validate_is_unique' do
  include ModelBuilder

  # Defines a model, create a validation and returns a raw matcher
  def define_and_validate(options={})
    @model = define_model :user, :id => DataMapper::Types::Serial, :username => String, :email => String, :public => DataMapper::Types::Boolean, :deleted_at => DateTime do
      validates_is_unique :username, options
    end

    # Create a model
    User.create(:username => 'jose', :deleted_at => 1.day.ago, :public => false)

    validate_is_unique(:username)
  end

  describe 'messages' do
    before(:each){ @matcher = define_and_validate }

    it 'should contain a description' do
      @matcher.description.should == 'require unique values for username'

      @matcher.nullable
      @matcher.description.should == 'require unique values for username allowing nil values'

      @matcher = validate_is_unique(:username, :scope => :email)
      @matcher.description.should == 'require unique values for username scoped to :email'

      @matcher = validate_is_unique(:username)
      @matcher.scope(:email)
      @matcher.scope(:public)
      @matcher.description.should == 'require unique values for username scoped to :email and :public'
    end

    it 'should set responds_to_scope? message' do
      @matcher.scope(:title).matches?(@model)
      @matcher.failure_message.should == 'Expected User instance responds to title='
    end

    it 'should set is_unique? message' do
      @matcher = validate_is_unique(:email)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected User to require unique values for email'
    end

    it 'should valid with new scope' do
      @matcher.scope(:email).matches?(@model)
      @matcher.failure_message.should == 'Expected User to be valid when username scope (email) change'
    end
  end

  describe 'matcher' do

    describe 'without options' do
      before(:each){ define_and_validate }

      it { should validate_is_unique(:username) }
      it { should_not validate_is_unique(:email) }
    end

    describe 'scoped to' do
      it { should define_and_validate(:scope => :email).scope(:email) }
      it { should define_and_validate(:scope => :public).scope(:public) }
      it { should define_and_validate(:scope => :deleted_at).scope(:deleted_at) }
      it { should define_and_validate(:scope => [:email, :public]).scope(:email, :public) }
      it { should define_and_validate(:scope => [:email, :public, :deleted_at]).scope(:email, :public, :deleted_at) }
      it { should_not define_and_validate(:scope => :email).scope(:title) }
      it { should_not define_and_validate(:scope => :email).scope(:public) }
    end

    create_message_specs(self)

    # Those are macros to test optionals which accept only boolean values
    create_optional_boolean_specs(:nullable, self)
  end

  describe 'errors' do
    it 'should raise an error if no object is found' do
      @matcher = define_and_validate
      User.all.destroy

      proc { @matcher.matches?(@model) }.should raise_error(ScriptError)
    end

    it 'should raise an error if no object with not nil attribute is found' do
      @matcher = define_and_validate.nullable
      User.all.destroy

      User.create(:username => nil)
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
      lambda { @matcher.matches?(@model) }.should raise_error(ScriptError)

      User.stub!(:find).and_return do |many, conditions|
        if many == :all
          1000.upto(1099).map{|i| User.new(:email => i) }
        else
          User.new(:username => 'jose')
        end
      end
      lambda { @matcher.matches?(@model) }.should_not raise_error(ScriptError)
    end

    describe 'when null values are not allowed' do
      def define_and_validate(options={})
        @model = define_model :user, :id => DataMapper::Types::Serial, :username => [String, {:nullable => false}] do
          validates_is_unique :username, options
        end

        User.create(:username => 'jose')
        validate_is_unique(:username)
      end

      it { should define_and_validate }
      it { should define_and_validate(:nullable => false).nullable(false) }

      it 'should raise an error if nullable is true but we cannot save nil values in the database'do
        lambda { should define_and_validate.nullable }.should raise_error(ScriptError, /You declared that username accepts nil values in validate_is_unique, but I cannot save nil values in the database, got/)
      end
    end
  end

  describe 'macros' do
    before(:each){ define_and_validate(:scope => :email) }

    should_validate_is_unique :username
    should_validate_is_unique :username, :scope => :email
    should_not_validate_is_unique :email
    should_not_validate_is_unique :username, :scope => :access_code

    should_validate_is_unique :username do |m|
      m.scope :email
    end
  end
end
