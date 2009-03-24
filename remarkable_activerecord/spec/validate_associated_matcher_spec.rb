require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'validate_associated' do
  include ModelBuilder

  # Defines a model, create a validation and returns a raw matcher
  def define_and_validate(macro, association, options={})
    define_model association, :name => :string do
      if options[:with_builder]
        validates_acceptance_of :name
      else
        validates_presence_of :name
      end
    end

    @model = define_model :project do
      send(macro, association, :validate => false) unless options[:skip_association]
      validates_associated association             unless options[:skip_validation]
    end

    validate_associated association
  end

  describe 'messages' do
    it 'should contain a description' do
      define_and_validate(:belongs_to, :company).description.should == 'require associated company to be valid'
    end

    it 'should set is_valid? message' do
      matcher = define_and_validate(:belongs_to, :company, :skip_validation => true)
      matcher.matches?(@model)
      matcher.failure_message.should == 'Expected Project to be invalid when company is invalid'
    end
  end

  describe 'error' do
    it 'should raise an error if the association does not exist' do
      lambda {
        should define_and_validate(:belongs_to, :company, :skip_association => true)
      }.should raise_error(ScriptError, 'Could not find association company on Project.')
    end

    it 'should raise an error if a singular association cannot be built' do
      lambda {
        matcher = define_and_validate(:belongs_to, :company)
        @model.should_receive(:build_company).and_raise(NoMethodError)
        should matcher
      }.should raise_error(ScriptError, 'The association object company could not be built. ' << 
                                        'You can give me :builder as option or a block which ' <<
                                        'returns an association.')
    end

    it 'should raise an error if a plural association cannot be built' do
      lambda {
        matcher = define_and_validate(:has_many, :tasks)
        @model.should_receive(:tasks).and_return(mock=mock('proxy'))
        mock.should_receive(:build).and_raise(NoMethodError)
        should matcher
      }.should raise_error(ScriptError, 'The association object tasks could not be built. ' << 
                                        'You can give me :builder as option or a block which ' <<
                                        'returns an association.')
    end

    it 'should raise an error if the associated object cannot be saved as invalid' do
      lambda {
        should define_and_validate(:belongs_to, :company, :with_builder => true)
      }.should raise_error(ScriptError, 'The associated object company is not invalid. ' << 
                                        'You can give me :builder as option or a block which ' << 
                                        'returns an invalid association.')
    end

    it 'should raise an error if the associated object cannot be saved even when a build is supplied' do
      lambda {
        should define_and_validate(:belongs_to, :company, :with_builder => true).builder(proc{ |p| p.build_company })
      }.should raise_error(ScriptError, 'The associated object company is not invalid. ' << 
                                        'You can give me :builder as option or a block which ' << 
                                        'returns an invalid association.')
    end
  end

  describe 'matchers' do
    it { should define_and_validate(:belongs_to, :company) }
    it { should define_and_validate(:has_one, :manager) }
    it { should define_and_validate(:has_many, :tasks) }
    it { should define_and_validate(:has_and_belongs_to_many, :tags) }

    it { should define_and_validate(:belongs_to, :company, :with_builder => true).builder(proc{|p| p.build_company(:name => true)}) }
    it { should define_and_validate(:has_one, :manager, :with_builder => true).builder(proc{|p| p.build_manager(:name => true)}) }
    it { should define_and_validate(:has_many, :tasks, :with_builder => true).builder(proc{|p| p.tasks.build(:name => true)}) }
    it { should define_and_validate(:has_and_belongs_to_many, :tags, :with_builder => true).builder(proc{|p| p.tags.build(:name => true)}) }

    it { should_not define_and_validate(:belongs_to, :company, :skip_validation => true) }
    it { should_not define_and_validate(:has_one, :manager, :skip_validation => true) }
    it { should_not define_and_validate(:has_many, :tasks, :skip_validation => true) }
    it { should_not define_and_validate(:has_and_belongs_to_many, :tags, :skip_validation => true) }
  end

  describe 'macros' do
    describe 'belongs to' do
      before(:each){ define_and_validate(:belongs_to, :company) }
      should_validate_associated(:company)
    end

    describe 'has_many with builder' do
      before(:each){ define_and_validate(:has_many, :tasks, :with_builder => true) }
      should_validate_associated(:tasks){ |p| p.tasks.build(:name => true) }
    end

    describe 'has_and_belongs_to_many with skip validation' do
      before(:each){ define_and_validate(:has_and_belongs_to_many, :tags, :skip_validation => true) }
      should_not_validate_associated(:tags)
    end
  end

end
