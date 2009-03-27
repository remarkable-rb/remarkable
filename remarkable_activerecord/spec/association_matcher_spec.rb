require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'association_matcher' do
  include ModelBuilder

  describe 'belong_to' do

    # Defines a model, create a validation and returns a raw matcher
    def define_and_validate(options={})
      columns = options.delete(:association_columns) || { :projects_count => :integer }
      define_model :company, columns

      columns = options.delete(:model_columns) || { :company_id => :integer, :company_type => :string }
      @model = define_model :project, columns do
        belongs_to :company, options
      end

      belong_to :company
    end

    describe 'messages' do
      it 'should contain a description' do
        matcher = define_and_validate
        matcher.description.should == 'belong to company'

        matcher.class_name('Company')
        matcher.description.should == 'belong to company with class name "Company"'

        matcher.foreign_key('company_id')
        matcher.description.should == 'belong to company with class name "Company" and with foreign key "company_id"'

        matcher = belong_to(:company).dependent(:destroy)
        matcher.description.should == 'belong to company with dependent :destroy'

        matcher.readonly
        matcher.description.should == 'belong to company with dependent :destroy and with readonly records'

        matcher.polymorphic
        matcher.description.should == 'belong to company with dependent :destroy, with readonly records, ' << 
                                       'and through a polymorphic interface'

        matcher.counter_cache('projects_count')
        matcher.description.should == 'belong to company with dependent :destroy, with readonly records, ' <<
                                       'through a polymorphic interface, and with counter cache "projects_count"'
      end

      it 'should set association_exists? message' do
        define_and_validate
        matcher = belong_to('whatever')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records belong to whatever, got no association'
      end

      it 'should set macro_matches? message' do
        define_and_validate
        matcher = have_one('company')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records have one company, got Project records belong to company'
      end

      it 'should set foreign_key_exists? message' do
        matcher = define_and_validate(:model_columns => {})
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected foreign key "company_id" to exist on "projects", but does not'
      end

      it 'should set polymorphic_exists? message' do
        matcher = define_and_validate(:model_columns => { :company_id => :integer }, :polymorphic => true)
        matcher.polymorphic.matches?(@model)
        matcher.failure_message.should == 'Expected "projects" to have "company_type" as column, but does not'
      end

      it 'should set counter_cache_exists? message' do
        matcher = define_and_validate(:association_columns => {}, :counter_cache => true)
        matcher.counter_cache.matches?(@model)
        matcher.failure_message.should == 'Expected "companies" to have "projects_count" as column, but does not'
      end

      it 'should set validate_matches? message' do
        matcher = define_and_validate(:validate => false)
        matcher.validate.matches?(@model)
        matcher.failure_message.should == 'Expected company association with validate equals to true, got "false"'
      end

      it 'should set readonly_matches? message' do
        matcher = define_and_validate(:readonly => false)
        matcher.readonly.matches?(@model)
        matcher.failure_message.should == 'Expected company association with readonly equals to true, got "false"'
      end

      it 'should set polymorphic_matches? message' do
        matcher = define_and_validate(:polymorphic => false)
        matcher.polymorphic.matches?(@model)
        matcher.failure_message.should == 'Expected company association with polymorphic equals to true, got "false"'
      end

      it 'should set counter_cache_matches? message' do
        matcher = define_and_validate(:counter_cache => true)
        matcher.counter_cache(false).matches?(@model)
        matcher.failure_message.should == 'Expected company association with counter cache false, got "true"'
      end
    end

    describe 'matchers' do
      describe 'without options' do
        before(:each){ define_and_validate }

        it { should belong_to(:company) }
        it { should_not belong_to(:project) }
        it { should_not have_one(:company) }
        it { should_not have_many(:company) }
      end

      describe 'with class name option' do
        it { should define_and_validate.class_name('Company') }
        it { should define_and_validate(:class_name => 'SuperCompany').class_name('SuperCompany') }

        it { should_not define_and_validate.class_name('SuperCompany') }
        it { should_not define_and_validate(:class_name => 'Company').class_name('SuperCompany') }
      end

      describe 'with foreign_key option' do
        it { should define_and_validate.foreign_key(:company_id) }
        it { should_not define_and_validate.foreign_key(:association_id) }

        # Checks whether fk exists or not
        it { should define_and_validate(:foreign_key => :association_id,
                                        :model_columns => { :association_id => :integer }).foreign_key(:association_id) }

        it { should_not define_and_validate(:foreign_key => :association_id).foreign_key(:association_id) }
        it { should_not define_and_validate(:model_columns => { :association_id => :integer }).foreign_key(:association_id) }
      end

      describe 'with dependent option' do
        it { should define_and_validate(:dependent => :delete).dependent(:delete) }
        it { should define_and_validate(:dependent => :destroy).dependent(:destroy) }

        it { should_not define_and_validate(:dependent => :delete).dependent(:destroy) }
        it { should_not define_and_validate(:dependent => :destroy).dependent(:delete) }
      end

      describe 'with counter_cache option' do
        # Checks whether fk exists or not
        it { should define_and_validate(:counter_cache => :association_count,
                                        :association_columns => { :association_count => :integer }).counter_cache(:association_count) }

        it { should_not define_and_validate(:counter_cache => :association_count).counter_cache(:association_count) }
        it { should_not define_and_validate(:association_columns => { :association_count => :integer }).counter_cache(:association_count) }
      end

      create_optional_boolean_specs(:readonly, self)
      create_optional_boolean_specs(:validate, self)
      create_optional_boolean_specs(:autosave, self) if RAILS_VERSION =~ /^2.3/
      create_optional_boolean_specs(:polymorphic, self)
      create_optional_boolean_specs(:counter_cache, self)
    end

    describe 'macros' do

    end
  end

end
