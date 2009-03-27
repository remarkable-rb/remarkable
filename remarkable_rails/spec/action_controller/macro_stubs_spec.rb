require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'MacroStubs' do
  controller_name 'tasks'

  def current_id; '37'; end

  describe 'when generating mocks' do
    mock_models :user

    before(:each) do
      self.class.send(:undef_method, :mock_task) if self.respond_to?(:mock_task)  
    end

    it 'should generate mock methods explicitely' do
      self.respond_to?(:mock_user).should be_true
    end

    it 'should create mock dynamically with class methods' do
      self.respond_to?(:mock_task).should be_false
      self.class.mock_task
      self.respond_to?(:mock_task).should be_true
    end

    it 'should create mock dynamically with instance methods' do
      self.instance_variable_get('@task').should be_nil
      self.respond_to?(:mock_task).should be_false

      mock_task

      self.instance_variable_get('@task').should_not be_nil
      self.respond_to?(:mock_task).should be_true
    end

    it 'should create procs which evals to mocks dynamically' do
      proc = self.class.mock_task
      proc.should be_kind_of(Proc)

      self.instance_variable_get('@task').should be_nil
      instance_eval &proc
      self.instance_variable_get('@task').should_not be_nil
    end
  end

  describe 'when extending describe group behavior' do
    expects :find, :on => Task, :with => proc{ current_id }, :returns => mock_task

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

    it 'should run expectations without performing an action' do
      self.should_receive(:current_id).once.and_return('37')
      run_expectations!
      @controller.send(:performed?).should_not be_true
      Task.find('37') # Execute expectations by hand
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
  end

  describe 'with matcher macros' do

    describe :delete => :destroy, :id => 37 do
      expects :find,    :on => Task,     :with => '37', :returns => mock_task
      expects :destroy, :on => mock_task

      subject { controller }

      should_assign_to :task
      should_assign_to :task, :with => mock_task
      should_assign_to :task, :with_kind_of => Task

      should_set_the_flash
      should_set_the_flash :notice
      should_set_the_flash :notice, :to => 'Task deleted.'

      should_set_session
      should_set_session :last_task_id
      should_set_session :last_task_id, :to => 37

      should_redirect_to{ project_tasks_url(10) }
      should_redirect_to proc{ project_tasks_url(10) }, :with => 302

      it 'should run action declared in describe' do
        @controller.send(:performed?).should_not be_true

        run_action!

        @controller.action_name.should == 'destroy'
        @controller.request.method.should == :delete
        @controller.send(:performed?).should be_true
      end

      it 'should provide a description based on parameters given in describe' do
        self.class.description.should =~ /responding to #DELETE destroy$/
      end
    end

  end
end
