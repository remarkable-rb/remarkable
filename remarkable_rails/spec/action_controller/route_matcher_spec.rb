require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController, 'routing', :type => :routing do

  def controller
    @controller ||= ApplicationController.new
  end

  describe 'messages' do
    before(:each) do
      @matcher = route(:get, '/projects', :controller => 'boo', :action => 'index')
    end

    it 'should contain a description message' do
      @matcher.description.should match(/route GET "\/projects" to\/from/)
    end

    it 'should set map_to_path? message' do
      @matcher.matches?(nil)
      @matcher.failure_message.should match(/Expected to map/)
    end

    it 'should set generate_params? message' do
      @matcher.stub!(:map_to_path?).and_return(true)
      @matcher.matches?(controller)
      @matcher.failure_message.should match(/Expected to generate params/)
    end
  end

  describe 'matchers' do
    it { should route(:get,    '/projects',     :controller => :projects, :action => :index) }
    it { should route(:delete, '/projects/1',   :controller => :projects, :action => :destroy, :id => 1) }
    it { should route(:get,    '/projects/new', :controller => :projects, :action => :new) }

    # to syntax
    it { should route(:get,    '/projects').to(:controller => :projects, :action => :index) }
    it { should route(:delete, '/projects/1').to(:controller => :projects, :action => :destroy, :id => 1) }
    it { should route(:get,    '/projects/new').to(:controller => :projects, :action => :new) }

    # from syntax
    it { should route(:get,    :controller => :projects, :action => :index).from('/projects') }
    it { should route(:delete, :controller => :projects, :action => :destroy, :id => 1).from('/projects/1') }
    it { should route(:get,    :controller => :projects, :action => :new).from('/projects/new') }

    # explicitly specify :controller
    it { should route(:post, '/projects',  :controller => :projects, :action => :create) }

    # non-string parameter
    it { should route(:get, '/projects/1', :controller => :projects, :action => :show, :id => 1) }

    # string-parameter
    it { should route(:put, '/projects/1', :controller => :projects, :action => :update, :id => "1") }

    # failing case
    it { should_not route(:get, '/projects', :controller => :projects, :action => :show) }
    it { should_not route(:xyz, '/projects', :controller => :projects, :action => :index) }
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
    should_not_route :xyz, '/projects',    :controller => :projects, :action => :index
  end

  describe 'using controller.request' do
    it "should extract environment from controller request" do
      ActionController::Routing::Routes.should_receive(:extract_request_environment).with(controller.request).and_return({:subdomain => "foo"})
      ActionController::Routing::Routes.should_receive(:recognize_path).with("/projects", {:subdomain => "foo", :method => :get})
      route(:get, '/projects', :controller => 'projects', :action => 'index').matches?(controller)
    end
  end
end

# Test implicit controller
describe TasksController, :type => :routing do
  should_route :get,    '/projects/5/tasks',     :action => :index,   :project_id => 5
  should_route :post,   '/projects/5/tasks',     :action => :create,  :project_id => 5
  should_route :get,    '/projects/5/tasks/1',   :action => :show,    :id => 1, :project_id => 5
  should_route :delete, '/projects/5/tasks/1',   :action => :destroy, :id => 1, :project_id => 5
  should_route :get,    '/projects/5/tasks/new', :action => :new,     :project_id => 5
  should_route :put,    '/projects/5/tasks/1',   :action => :update,  :id => 1, :project_id => 5

  it "should use another controller name if it's given" do
    self.should_receive(:controller).and_return(ApplicationController.new)
    route(:get, '/').send(:controller_name).should == 'applications'
  end
end
