require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'association_matcher' do
  include ModelBuilder

  describe 'have_one' do

    # Defines a model, create a validation and returns a raw matcher
    def define_and_validate(options={})
      columns = options.delete(:association_columns) || { :manager_id => :integer, :project_id => :integer, :director_id => :integer }
      define_model :manager, columns
      define_model :director,    columns

      define_model :project_manager, columns do
        belongs_to :manager
        belongs_to :project
        belongs_to :director
      end unless options.delete(:skip_source)

      @model = define_model :project, options.delete(:model_columns) || {} do
        has_many :project_managers unless options.delete(:skip_through)
        has_one  :manager, options
        has_one  :unknown
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
        matcher.failure_message.should == 'Expected Project records have one whatever, but the association does not exist'
      end

      it 'should set klass_exists? message' do
        define_and_validate
        matcher = have_one('unknown')
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Project records have one unknown, but the association class does not exist'
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

      it 'should set options_matches? message when dependent is given' do
        matcher = define_and_validate(:dependent => :destroy)
        matcher.dependent(:nullify).matches?(@model)
        matcher.failure_message.should == 'Expected Project records have one manager with options {:dependent=>"nullify"}, got {:dependent=>"destroy"}'
      end

      it 'should set options_matches? message when source is given' do
        matcher = define_and_validate(:through => :project_managers, :source => :director)
        matcher.through(:project_managers).source(:manager).matches?(@model)
        matcher.failure_message.should match(/:source=>"manager"/)
        matcher.failure_message.should match(/:source=>"director"/)
      end
    end

    describe 'matchers' do
      describe 'without options' do
        before(:each){ define_and_validate }

        it { should have_one(:manager) }
        it { should_not have_one(:unknown) }
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

      describe 'with source option' do
        it { should define_and_validate(:through => :project_managers, :source => :director).source(:director) }
        it { should_not define_and_validate(:through => :project_managers, :source => :director).source(:manager) }
      end

      create_optional_boolean_specs(:validate, self)
    end

    describe 'macros' do
      before(:each){ define_and_validate(:through => :project_managers, :validate => true) } 

      should_have_one :manager
      should_have_one :manager, :validate => true
      should_have_one :manager, :through => :project_managers

      should_have_one :manager do |m|
        m.validate
        m.through = :project_managers
      end

      should_not_have_one :unknown
      should_not_have_one :manager, :validate => false
      should_not_have_one :manager, :through => :another_thing
    end
  end

end
