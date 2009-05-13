require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# Define a metaclass in the Object because we are going to need it.
class Object; def metaclass; class << self; self; end; end; end

describe 'MacroStubs' do
  controller_name 'tasks'
  mock_models :task

  def current_id; '37'; end

  describe 'mock_models' do
    before(:each) do
      self.class.metaclass.send(:undef_method, :mock_project) if self.class.respond_to?(:mock_project)
      self.class.send(:undef_method, :mock_project)           if self.respond_to?(:mock_project)
    end

    it 'should create a class mock method' do
      self.class.respond_to?(:mock_project).should be_false
      self.class.mock_models :project
      self.class.respond_to?(:mock_project).should be_true
    end

    it 'should create an instance mock method' do
      self.respond_to?(:mock_project).should be_false
      self.class.mock_models :project
      self.respond_to?(:mock_project).should be_true
    end

    it 'should create just an instance method when :class_method is false' do
      self.class.respond_to?(:mock_project).should be_false
      self.respond_to?(:mock_project).should be_false
      self.class.mock_models :project, :class_method => false
      self.class.respond_to?(:mock_project).should be_false
      self.respond_to?(:mock_project).should be_true
    end

    it 'should create procs which evals to mocks dynamically' do
      proc = self.class.mock_task
      proc.should be_kind_of(Proc)

      self.instance_variable_get('@task').should be_nil
      instance_eval(&proc)
      self.instance_variable_get('@task').should_not be_nil
    end
  end

  describe 'failures' do
    expects :find, :on => Task, :with => proc{ current_id }, :returns => mock_task
    expects :max, :min, :count, :on => Task, :ordered => true

    get :show, :id => 37

    it 'should fail if expectation is not met' do
      self.stub!(:current_id).and_return("42")

      lambda {
        run_action!(true)
      }.should raise_error(Spec::Mocks::MockExpectationError, /expected :find with \("42"\) but received it with \("37"\)/)
    end

    it 'should fail if expectations are received out of order' do
      lambda {
        run_action!(true)
      }.should raise_error(Spec::Mocks::MockExpectationError, /received :count out of order/)
    end

    it 'should splat an array given to with' do
      self.stub!(:current_id).and_return([1, 2, 3])
      run_expectations!

      lambda {
        Task.find([1,2,3])
      }.should raise_error(Spec::Mocks::MockExpectationError, /expected :find with \(1\, 2\, 3\) but received it with \(\[1\, 2\, 3\]\)/)

      lambda {
        Task.find(1, 2, 3)
      }.should_not raise_error
    end

    after(:each) do
      teardown_mocks_for_rspec
    end
  end

  describe 'when extending describe group behavior' do
    expects :find, :on => Task, :with => proc{ current_id }, :returns => mock_task
    expects :count, :max, :min, :on => Task

    get :show, :id => 37
    params :special_task_id => 42
    mime Mime::HTML

    it 'should run action declared in a class method' do
      @controller.send(:performed?).should_not be_true

      run_action!(false)

      @controller.action_name.should == 'show'
      @controller.request.method.should == :get
      @controller.send(:performed?).should be_true
    end

    it 'should use parameters given in params on request' do
      self.should_receive(:current_id).once.and_return('37')
      run_action!
      @request.parameters[:special_task_id].should == '42'
    end

    it 'should respond with the supplied mime type' do
      self.should_receive(:current_id).once.and_return('37')
      run_action!
      @response.content_type.should == Mime::HTML.to_s
    end

    it 'should run action with expectations' do
      self.should_receive(:current_id).once.and_return('37')
      run_action!
      @controller.send(:performed?).should be_true
    end

    it 'should not run action twice' do
      run_action!
      @controller.send(:performed?).should be_true
      proc{ run_action!.should be_false }.should_not raise_error
    end

    it 'should run expectations without performing an action' do
      self.should_receive(:current_id).once.and_return('37')
      run_expectations!
      @controller.send(:performed?).should_not be_true
      get :show, :id => '37' # Execute the action to match expectations
    end

    it 'should run action with stubs' do
      self.should_receive(:current_id).never
      run_action!(false)
      @controller.send(:performed?).should be_true
    end

    it 'should run stubs without performing an action' do
      self.should_receive(:current_id).never
      run_stubs!
      @controller.send(:performed?).should_not be_true
    end

    describe Mime::XML do
      expects :to_xml, :on => mock_task, :returns => 'XML'

      it 'should provide a description based on the mime given in describe' do
        self.class.description.should =~ /with xml$/
      end

      it 'should run action based on inherited declarations' do
        @controller.send(:performed?).should_not be_true

        run_action!

        @controller.action_name.should == 'show'
        @controller.request.method.should == :get
        @controller.send(:performed?).should be_true
        @controller.response.body.should == 'XML'
        @request.parameters[:special_task_id].should == '42'
      end
    end

    describe 'and running actions in a before(:all) filter' do
      get :show, :id => 37

      get! do
        @request.should_not be_nil
      end

      get! do
        @flag = true
      end

      get! do
        @controller.should_not be_nil
      end

      it 'should run the action before each example' do
        @controller.send(:performed?).should be_true
      end

      it 'should execute the given block' do
        @flag.should be_true
      end
    end
  end

  describe 'with matcher macros' do

    [:delete, :delete!].each do |method|

      describe method => :destroy, :id => '37' do
        expects :find,    :on => Task, :with => '37', :returns => mock_task
        expects :destroy, :on => mock_task
        expects :title,   :on => mock_task, :with => false do |boolean|
          if boolean
            'This should not appear'
          else
            'My favourite task'
          end
        end

        xhr!
        subject { controller }

        should_assign_to :task
        should_assign_to :task, :with => mock_task
        should_assign_to :task, :with_kind_of => Task

        should_set_the_flash
        should_set_the_flash :notice
        should_set_the_flash :notice, :to => %{"My favourite task" was removed}

        should_set_session
        should_set_session :last_task_id
        should_set_session :last_task_id, :to => 37

        should_redirect_to{ project_tasks_url(10) }
        should_redirect_to proc{ project_tasks_url(10) }, :with => 302

        it 'should run action declared in describe' do
          @controller.send(:performed?).should_not be_true unless method == :delete!

          run_action!

          @controller.action_name.should == 'destroy'
          @controller.request.method.should == :delete
          @controller.send(:performed?).should be_true
        end

        it 'should provide a description based on parameters given in describe' do
          self.class.description.should =~ /responding to #DELETE destroy$/
        end

        it 'should perform a XmlHttpRequest' do
          run_action!
          request.env['HTTP_X_REQUESTED_WITH'].should == 'XMLHttpRequest'
        end
      end

    end

  end
end
