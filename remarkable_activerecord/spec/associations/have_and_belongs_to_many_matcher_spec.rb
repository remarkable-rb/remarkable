require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'association_matcher' do
  include ModelBuilder

  describe 'have_and_belong_to_many' do

    # Defines a model, create a validation and returns a raw matcher
    def define_and_validate(options={})
      define_model :label
      define_model :super_label

      columns = options.delete(:association_columns) || [ :label_id, :project_id ]
      create_table(options.delete(:association_table) || :labels_projects, :id => false) do |table|
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
        matcher.failure_message.should == 'Expected Project records have and belong to many whatever, but the association does not exist'
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
        matcher = define_and_validate(:association_columns => [:label_id])
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

        it { should define_and_validate(:join_table => :my_table,
                                        :association_table => :my_table).join_table(:my_table) }

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
    end

    describe 'macros' do
      before(:each){ define_and_validate(:validate => true, :readonly => true) }

      should_have_and_belong_to_many :labels
      should_have_and_belong_to_many :labels, :readonly    => true
      should_have_and_belong_to_many :labels, :validate    => true
      should_have_and_belong_to_many :labels, :class_name  => "Label"
      should_have_and_belong_to_many :labels, :foreign_key => :project_id

      should_have_and_belong_to_many :labels do |m|
        m.readonly
        m.validate
        m.class_name "Label"
        m.foreign_key :project_id
      end

      should_not_have_and_belong_to_many :companies
      should_not_have_one  :label
      should_not_have_many :labels

      should_not_have_and_belong_to_many :labels, :readonly    => false
      should_not_have_and_belong_to_many :labels, :validate    => false
      should_not_have_and_belong_to_many :labels, :class_name  => "Anything"
      should_not_have_and_belong_to_many :labels, :foreign_key => :anything_id
    end
  end

end
