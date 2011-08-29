require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'association_matcher' do
  include ModelBuilder

  describe 'have_many' do

    # Defines a model, create a validation and returns a raw matcher
    def define_and_validate(options={})
      columns = options.delete(:association_columns) || { :task_id => :integer, :project_id => :integer, :todo_id => :integer }
      define_model :task, columns
      define_model :todo, columns

      define_model :project_task, columns do
        belongs_to :task
        belongs_to :project
        belongs_to :todo
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
        matcher.failure_message.should == 'Expected Project records have many whatever, but the association does not exist'
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

      it 'should set options_matches? message when dependent is given' do
        matcher = define_and_validate(:dependent => :destroy)
        matcher.dependent(:nullify).matches?(@model)
        matcher.failure_message.should == 'Expected Project records have many tasks with options {:dependent=>"nullify"}, got {:dependent=>"destroy"}'
      end

      it 'should set options_matches? message when source is given' do
        matcher = define_and_validate(:through => :project_tasks, :source => :todo)
        matcher.through(:project_tasks).source(:task).matches?(@model)
        matcher.failure_message.should match(/:source=>"task"/)
        matcher.failure_message.should match(/:source=>"todo"/)
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

      describe 'with source option' do
        it { should define_and_validate(:through => :project_tasks, :source => :todo).source(:todo) }
        it { should_not define_and_validate(:through => :project_tasks, :source => :todo).source(:task) }
      end

      create_optional_boolean_specs(:uniq, self)
      create_optional_boolean_specs(:readonly, self)
      create_optional_boolean_specs(:validate, self)
    end

    describe 'macros' do
      before(:each){ define_and_validate(:through => :project_tasks, :readonly => true, :validate => true) } 

      should_have_many :tasks
      should_have_many :tasks, :readonly => true
      should_have_many :tasks, :validate => true
      should_have_many :tasks, :through => :project_tasks

      should_have_many :tasks do |m|
        m.readonly
        m.validate
        m.through = :project_tasks
      end

      should_not_have_many :tasks, :readonly => false
      should_not_have_many :tasks, :validate => false
      should_not_have_many :tasks, :through => :another_thing
    end
  end

end
