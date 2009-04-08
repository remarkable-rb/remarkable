require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'route_matcher' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @matcher = route(:get, '/projects', :controller => 'boo', :action => 'index')
    end

    it 'should contain a description message' do
      @matcher.description.should == 'route GET "/projects" to/from {:controller=>"boo", :action=>"index"}'
    end

    it 'should set map_to_path? message' do
      @matcher.matches?(nil)
      @matcher.failure_message.should == 'Expected to map {:controller=>"boo", :action=>"index"} to GET "/projects", got "/boo"'
    end

    it 'should set map_to_path? message' do
      @matcher.stub!(:map_to_path?).and_return(true)
      @matcher.matches?(nil)
      @matcher.failure_message.should == 'Expected to generate params {:controller=>"boo", :action=>"index"} from GET "/projects", got {:controller=>"projects", :action=>"index"}'
    end
  end

  describe 'matchers' do
    it { should route(:get,    '/projects',     :controller => :projects, :action => :index) }
    it { should route(:delete, '/projects/1',   :controller => :projects, :action => :destroy, :id => 1) }
    it { should route(:get,    '/projects/new', :controller => :projects, :action => :new) }

    # explicitly specify :controller
    it { should route(:post,   '/projects',     :controller => :projects, :action => :create) }

    # non-string parameter
    it { should route(:get,    '/projects/1',   :controller => :projects, :action => :show, :id => 1) }

    # string-parameter
    it { should route(:put,    '/projects/1',   :controller => :projects, :action => :update, :id => "1") }

    # failing case
    it { should_not route(:get, '/projects',    :controller => :projects, :action => :show) }
  end

  describe 'macros' do
    should_route :get,    '/projects',     :controller => :projects, :action => :index
    should_route :delete, '/projects/1',   :controller => :projects, :action => :destroy, :id => 1
    should_route :get,    '/projects/new', :controller => :projects, :action => :new

    # explicitly specify :controller
    should_route :post,   '/projects',     :controller => :projects, :action => :create

    # non-string parameter
    should_route :get,    '/projects/1',   :controller => :projects, :action => :show,    :id => 1

    # string-parameter
    should_route :put,    '/projects/1',   :controller => :projects, :action => :update,  :id => "1"

    # failing case
    should_not_route :get, '/projects',    :controller => :projects, :action => :show
  end

  describe TasksController, :type => :routing do
    controller_name 'tasks'

    # Test the nested routes with implicit controller
    should_route :get,    '/projects/5/tasks',     :action => :index,   :project_id => 5
    should_route :post,   '/projects/5/tasks',     :action => :create,  :project_id => 5
    should_route :get,    '/projects/5/tasks/1',   :action => :show,    :id => 1, :project_id => 5
    should_route :delete, '/projects/5/tasks/1',   :action => :destroy, :id => 1, :project_id => 5
    should_route :get,    '/projects/5/tasks/new', :action => :new,     :project_id => 5
    should_route :put,    '/projects/5/tasks/1',   :action => :update,  :id => 1, :project_id => 5
  end

end
