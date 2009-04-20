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
      before(:each){ define_and_validate(:validate => true, :readonly => true) }

      should_belong_to :company
      should_belong_to :company, :readonly    => true
      should_belong_to :company, :validate    => true
      should_belong_to :company, :class_name  => "Company"
      should_belong_to :company, :foreign_key => :company_id

      should_not_belong_to :project
      should_not_have_one  :company
      should_not_have_many :companies

      should_not_belong_to :company, :readonly    => false
      should_not_belong_to :company, :validate    => false
      should_not_belong_to :company, :class_name  => "Anything"
      should_not_belong_to :company, :foreign_key => :anything_id
    end
  end

  describe 'have_and_belong_to_many' do

    # Defines a model, create a validation and returns a raw matcher
    def define_and_validate(options={})
      define_model :label

      columns = options.delete(:association_columns) || [ :label_id, :project_id ]
      create_table(options.delete(:association_table) || :labels_projects) do |table|
        columns.each { |name| table.column(name, :integer) }
      end

      @model = define_model :project, options.delete(:model_columns) || {} do
        has_and_belongs_to_many :labels, options
      end

      have_and_belong_to_many :labels
    end

    describe 'messages' do
      it 'should contain a description' do
        matcher = define_and_validate
        matcher.description.should == 'have and belong to many labels'

        matcher.class_name('Label')
        matcher.description.should == 'have and belong to many labels with class name "Label"'

        matcher.foreign_key('label_id')
        matcher.description.should == 'have and belong to many labels with class name "Label" and with foreign key "label_id"'

        matcher = have_and_belong_to_many(:labels).autosave
        matcher.description.should == 'have and belong to many labels autosaving associated records'

        matcher.uniq
        matcher.description.should == 'have and belong to many labels with unique records and autosaving associated records'
      end

      it 'should set association_exists? message' do
        define_and_validate
        matcher = have_and_belong_to_many('whatever')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records have and belong to many whatever, got no association'
      end

      it 'should set macro_matches? message' do
        define_and_validate
        matcher = have_many('labels')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records have many labels, got Project records have and belong to many labels'
      end

      it 'should set join_table_exists? message' do
        matcher = define_and_validate(:association_table => 'another_name')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected join table "labels_projects" to exist, but does not'
      end

      it 'should set foreign_key_exists? message' do
        matcher = define_and_validate(:association_columns => [])
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected foreign key "project_id" to exist on "labels_projects", but does not'
      end

      it 'should set options_matches? message' do
        matcher = define_and_validate(:uniq => false)
        matcher.uniq.matches?(@model)
        matcher.failure_message.should == 'Expected Project records have and belong to many labels with options {:uniq=>"true"}, got {:uniq=>"false"}'
      end
    end

    describe 'matchers' do
      describe 'without options' do
        before(:each){ define_and_validate }

        it { should have_and_belong_to_many(:labels) }
        it { should_not belong_to(:label) }
        it { should_not have_one(:label) }
        it { should_not have_many(:labels) }
        it { should_not have_and_belong_to_many(:companies) }
      end

      describe 'with class name option' do
        it { should define_and_validate.class_name('Label') }

        it { should define_and_validate(:class_name => 'SuperLabel',
                                        :association_table => 'projects_super_labels').class_name('SuperLabel') }

        it { should_not define_and_validate.class_name('SuperLabel') }
      end

      describe 'with foreign_key option' do
        it { should define_and_validate.foreign_key(:project_id) }
        it { should_not define_and_validate.foreign_key(:association_id) }

        # Checks whether fk exists or not
        it { should define_and_validate(:foreign_key => :association_id,
                                        :association_columns => [ :association_id ]).foreign_key(:association_id) }

        it { should_not define_and_validate(:foreign_key => :association_id).foreign_key(:association_id) }
        it { should_not define_and_validate(:association_columns => [ :association_id ]).foreign_key(:association_id) }
      end

      describe 'with join table option' do
        it { should define_and_validate.join_table('labels_projects') }
        it { should define_and_validate(:join_table => 'my_table',
                                        :association_table => 'my_table').join_table('my_table') }

        it { should_not define_and_validate.join_table('projects_labels') }

        it { should_not define_and_validate(:join_table => 'my_table',
                                            :association_table => 'another_table').join_table('my_table') }
        it { should_not define_and_validate(:join_table => 'another_table',
                                            :association_table => 'my_table').join_table('my_table') }
        it { should_not define_and_validate(:join_table => 'my_table',
                                            :association_table => 'my_table').join_table('another_table') }
      end

      create_optional_boolean_specs(:uniq, self)
      create_optional_boolean_specs(:readonly, self)
      create_optional_boolean_specs(:validate, self)
      create_optional_boolean_specs(:autosave, self) if RAILS_VERSION =~ /^2.3/
    end

    describe 'macros' do
      before(:each){ define_and_validate(:validate => true, :readonly => true) }

      should_have_and_belong_to_many :labels
      should_have_and_belong_to_many :labels, :readonly    => true
      should_have_and_belong_to_many :labels, :validate    => true
      should_have_and_belong_to_many :labels, :class_name  => "Label"
      should_have_and_belong_to_many :labels, :foreign_key => :project_id

      should_not_have_and_belong_to_many :companies
      should_not_have_one  :label
      should_not_have_many :labels

      should_not_have_and_belong_to_many :labels, :readonly    => false
      should_not_have_and_belong_to_many :labels, :validate    => false
      should_not_have_and_belong_to_many :labels, :class_name  => "Anything"
      should_not_have_and_belong_to_many :labels, :foreign_key => :anything_id
    end
  end

  describe 'have_many' do

    # Defines a model, create a validation and returns a raw matcher
    def define_and_validate(options={})
      columns = options.delete(:association_columns) || { :task_id => :integer, :project_id => :integer }
      define_model :task, columns

      define_model :project_task, columns do
        belongs_to :task
        belongs_to :project
      end unless options.delete(:skip_source)

      @model = define_model :project, options.delete(:model_columns) || {} do
        has_many :project_tasks unless options.delete(:skip_through)
        has_many :tasks, options
      end

      have_many :tasks
    end

    describe 'messages' do
      it 'should contain a description' do
        matcher = define_and_validate
        matcher.description.should == 'have many tasks'

        matcher.class_name('Task')
        matcher.description.should == 'have many tasks with class name "Task"'

        matcher.foreign_key('task_id')
        matcher.description.should == 'have many tasks with class name "Task" and with foreign key "task_id"'

        matcher = have_many(:tasks).autosave
        matcher.description.should == 'have many tasks autosaving associated records'

        matcher.uniq
        matcher.description.should == 'have many tasks with unique records and autosaving associated records'
      end

      it 'should set association_exists? message' do
        define_and_validate
        matcher = have_many('whatever')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records have many whatever, got no association'
      end

      it 'should set macro_matches? message' do
        define_and_validate
        matcher = have_and_belong_to_many('tasks')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records have and belong to many tasks, got Project records have many tasks'
      end

      it 'should set foreign_key_exists? message' do
        matcher = define_and_validate(:association_columns => {})
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected foreign key "project_id" to exist on "tasks", but does not'
      end

      it 'should set through_exists? message' do
        matcher = define_and_validate(:through => :project_tasks, :skip_through => true)
        matcher.through(:project_tasks).matches?(@model)
        matcher.failure_message.should == 'Expected Project records have many tasks through :project_tasks, through association does not exist'
      end

      it 'should set source_exists? message' do
        matcher = define_and_validate(:through => :project_tasks, :skip_source => true)
        matcher.through(:project_tasks).matches?(@model)
        matcher.failure_message.should == 'Expected Project records have many tasks through :project_tasks, source association does not exist'
      end

      it 'should set options_matches? message' do
        matcher = define_and_validate(:dependent => :destroy)
        matcher.dependent(:nullify).matches?(@model)
        matcher.failure_message.should == 'Expected Project records have many tasks with options {:dependent=>"nullify"}, got {:dependent=>"destroy"}'
      end
    end

    describe 'matchers' do
      describe 'without options' do
        before(:each){ define_and_validate }

        it { should have_many(:tasks) }
        it { should_not belong_to(:task) }
        it { should_not have_one(:task) }
        it { should_not have_and_belong_to_many(:tasks) }
      end

      describe 'with class name option' do
        before(:each){ define_model :super_task, :project_id => :integer }

        it { should define_and_validate.class_name('Task') }
        it { should define_and_validate(:class_name => 'SuperTask').class_name('SuperTask') }

        it { should_not define_and_validate.class_name('SuperTask') }
        it { should_not define_and_validate(:class_name => 'SuperTask').class_name('Task') }
      end

      describe 'with foreign_key option' do
        it { should define_and_validate.foreign_key(:project_id) }
        it { should_not define_and_validate.foreign_key(:association_id) }

        # Checks whether fk exists or not
        it { should define_and_validate(:foreign_key => :association_id,
                                        :association_columns => { :association_id => :integer }).foreign_key(:association_id) }

        it { should_not define_and_validate(:foreign_key => :association_id).foreign_key(:association_id) }
        it { should_not define_and_validate(:association_columns => { :association_id => :integer }).foreign_key(:association_id) }
      end

      describe 'with dependent option' do
        it { should define_and_validate(:dependent => :delete_all).dependent(:delete_all) }
        it { should define_and_validate(:dependent => :destroy).dependent(:destroy) }

        it { should_not define_and_validate(:dependent => :delete_all).dependent(:destroy) }
        it { should_not define_and_validate(:dependent => :destroy).dependent(:delete_all) }
      end

      describe 'with through option' do
        it { should define_and_validate(:through => :project_tasks) }
        it { should define_and_validate(:through => :project_tasks).through(:project_tasks) }

        it { should_not define_and_validate(:through => :project_tasks).through(:something) }
        it { should_not define_and_validate(:through => :project_tasks, :skip_through => true).through(:project_tasks) }
      end

      create_optional_boolean_specs(:uniq, self)
      create_optional_boolean_specs(:readonly, self)
      create_optional_boolean_specs(:validate, self)
      create_optional_boolean_specs(:autosave, self) if RAILS_VERSION =~ /^2.3/
    end

    describe 'macros' do
      before(:each){ define_and_validate(:through => :project_tasks, :readonly => true, :validate => true) } 

      should_have_many :tasks
      should_have_many :tasks, :readonly => true
      should_have_many :tasks, :validate => true
      should_have_many :tasks, :through => :project_tasks

      should_not_have_many :tasks, :readonly => false
      should_not_have_many :tasks, :validate => false
      should_not_have_many :tasks, :through => :another_thing
    end
  end

  describe 'have_one' do

    # Defines a model, create a validation and returns a raw matcher
    def define_and_validate(options={})
      columns = options.delete(:association_columns) || { :manager_id => :integer, :project_id => :integer }
      define_model :manager, columns

      define_model :project_manager, columns do
        belongs_to :manager
        belongs_to :project
      end unless options.delete(:skip_source)

      @model = define_model :project, options.delete(:model_columns) || {} do
        has_many :project_managers unless options.delete(:skip_through)
        has_one  :manager, options
      end

      have_one :manager
    end

    describe 'messages' do
      it 'should contain a description' do
        matcher = define_and_validate
        matcher.description.should == 'have one manager'

        matcher.class_name('Manager')
        matcher.description.should == 'have one manager with class name "Manager"'

        matcher.foreign_key('manager_id')
        matcher.description.should == 'have one manager with class name "Manager" and with foreign key "manager_id"'
      end

      it 'should set association_exists? message' do
        define_and_validate
        matcher = have_one('whatever')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records have one whatever, got no association'
      end

      it 'should set macro_matches? message' do
        define_and_validate
        matcher = belong_to('manager')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records belong to manager, got Project records have one manager'
      end

      it 'should set foreign_key_exists? message' do
        matcher = define_and_validate(:association_columns => {})
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected foreign key "project_id" to exist on "managers", but does not'
      end

      it 'should set through_exists? message' do
        matcher = define_and_validate(:through => :project_managers, :skip_through => true)
        matcher.through(:project_managers).matches?(@model)
        matcher.failure_message.should == 'Expected Project records have one manager through :project_managers, through association does not exist'
      end

      it 'should set source_exists? message' do
        matcher = define_and_validate(:through => :project_managers, :skip_source => true)
        matcher.through(:project_managers).matches?(@model)
        matcher.failure_message.should == 'Expected Project records have one manager through :project_managers, source association does not exist'
      end

      it 'should set options_matches? message' do
        matcher = define_and_validate(:dependent => :destroy)
        matcher.dependent(:nullify).matches?(@model)
        matcher.failure_message.should == 'Expected Project records have one manager with options {:dependent=>"nullify"}, got {:dependent=>"destroy"}'
      end
    end

    describe 'matchers' do
      describe 'without options' do
        before(:each){ define_and_validate }

        it { should have_one(:manager) }
        it { should_not belong_to(:manager) }
        it { should_not have_many(:managers) }
        it { should_not have_and_belong_to_many(:managers) }
      end

      describe 'with class name option' do
        before(:each){ define_model :super_manager, :project_id => :integer }

        it { should define_and_validate.class_name('Manager') }
        it { should define_and_validate(:class_name => 'SuperManager').class_name('SuperManager') }

        it { should_not define_and_validate.class_name('SuperManager') }
        it { should_not define_and_validate(:class_name => 'SuperManager').class_name('Manager') }
      end

      describe 'with foreign_key option' do
        it { should define_and_validate.foreign_key(:project_id) }
        it { should_not define_and_validate.foreign_key(:association_id) }

        # Checks whether fk exists or not
        it { should define_and_validate(:foreign_key => :association_id,
                                        :association_columns => { :association_id => :integer }).foreign_key(:association_id) }

        it { should_not define_and_validate(:foreign_key => :association_id).foreign_key(:association_id) }
        it { should_not define_and_validate(:association_columns => { :association_id => :integer }).foreign_key(:association_id) }
      end

      describe 'with dependent option' do
        it { should define_and_validate(:dependent => :delete).dependent(:delete) }
        it { should define_and_validate(:dependent => :destroy).dependent(:destroy) }

        it { should_not define_and_validate(:dependent => :delete).dependent(:destroy) }
        it { should_not define_and_validate(:dependent => :destroy).dependent(:delete) }
      end

      describe 'with through option' do
        it { should define_and_validate(:through => :project_managers) }
        it { should define_and_validate(:through => :project_managers).through(:project_managers) }

        it { should_not define_and_validate(:through => :project_managers).through(:something) }
        it { should_not define_and_validate(:through => :project_managers, :skip_through => true).through(:project_managers) }
      end

      create_optional_boolean_specs(:validate, self)
      create_optional_boolean_specs(:autosave, self) if RAILS_VERSION =~ /^2.3/
    end

    describe 'macros' do
      before(:each){ define_and_validate(:through => :project_managers, :validate => true) } 

      should_have_one :manager
      should_have_one :manager, :validate => true
      should_have_one :manager, :through => :project_managers

      should_not_have_one :manager, :validate => false
      should_not_have_one :manager, :through => :another_thing
    end
  end

end
