require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'association_matcher' do
  include ModelBuilder

  describe 'belong_to' do

    # Defines a model, create a validation and returns a raw matcher
    def define_and_validate(options={})
      columns = options.delete(:association_columns) || { :projects_count => :integer }
      define_model :company, columns
      define_model :super_company, columns

      columns = options.delete(:model_columns) || { :company_id => :integer, :company_type => :string }
      @model = define_model :project, columns do
        belongs_to :company, options
        belongs_to :unknown
        belongs_to :accountable, :polymorphic => true
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

        matcher.as(:interface)
        matcher.description.should == 'belong to company with dependent :destroy, through the polymorphic interface :interface, and with readonly records'

        matcher.counter_cache('projects_count')
        matcher.description.should == 'belong to company with dependent :destroy, through the polymorphic interface :interface, ' <<
                                      'with readonly records, and with counter cache "projects_count"'
      end

      it 'should set association_exists? message' do
        define_and_validate
        matcher = belong_to('whatever')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records belong to whatever, but the association does not exist'
      end

      it 'should set macro_matches? message' do
        define_and_validate
        matcher = have_one('company')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records have one company, got Project records belong to company'
      end

      it 'should set klass_exists? message' do
        define_and_validate
        matcher = belong_to('unknown')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records belong to unknown, but the association class does not exist'
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

      it 'should set options_matches? message when polymorphic is given' do
        matcher = define_and_validate(:polymorphic => false)
        matcher.polymorphic.matches?(@model)
        matcher.failure_message.should == 'Expected Project records belong to company with options {:polymorphic=>"true"}, got {:polymorphic=>"false"}'
      end

      it 'should set options_matches? message when counter_cache is given' do
        matcher = define_and_validate(:counter_cache => true)
        matcher.counter_cache(false).matches?(@model)
        matcher.failure_message.should == 'Expected Project records belong to company with options {:counter_cache=>"false"}, got {:counter_cache=>"true"}'
      end
    end

    describe 'matchers' do
      describe 'without options' do
        before(:each){ define_and_validate }

        it { should belong_to(:company) }
        it { should_not belong_to(:unknown) }
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

      describe "with polymorphic option" do
        before(:each){ define_and_validate(:model_columns => {:accountable_id => :integer, :accountable_type => :string}) }
        it { should belong_to(:accountable).polymorphic }
      end

      create_optional_boolean_specs(:readonly, self)
      create_optional_boolean_specs(:validate, self)
      create_optional_boolean_specs(:polymorphic, self)
      create_optional_boolean_specs(:counter_cache, self)
    end

    describe 'macros' do
      before(:each){ define_and_validate(:validate => true, :readonly => true) }

      should_belong_to :company
      should_belong_to :company, :readonly    => true
      should_belong_to :company, :validate    => true
      should_belong_to :company, :class_name  => "Company"
      should_belong_to :company, :foreign_key => :company_id

      should_belong_to :company do |m|
        m.readonly
        m.validate
        m.class_name = "Company"
        m.foreign_key = :company_id
      end

      should_not_belong_to :unknown
      should_not_belong_to :project
      should_not_have_one  :company
      should_not_have_many :companies

      should_not_belong_to :company, :readonly    => false
      should_not_belong_to :company, :validate    => false
      should_not_belong_to :company, :class_name  => "Anything"
      should_not_belong_to :company, :foreign_key => :anything_id
    end
  end

end
