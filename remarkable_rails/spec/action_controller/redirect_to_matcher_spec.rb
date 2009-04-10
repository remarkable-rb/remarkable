require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'redirect_to' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      build_response { redirect_to projects_url }
      @matcher = redirect_to(project_tasks_url(1)).with(302)
    end

    it 'should contain a description message' do
      @matcher = redirect_to(project_tasks_url(1))
      @matcher.description.should == 'redirect to "http://test.host/projects/1/tasks"'

      @matcher.with(301)
      @matcher.description.should == 'redirect to "http://test.host/projects/1/tasks" with status 301'
    end

    it 'should set redirected? message' do
      build_response
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected redirect to "http://test.host/projects/1/tasks", got no redirect'
    end

    it 'should set status_matches? message' do
      @matcher.with(200).matches?(@controller)
      @matcher.failure_message.should == 'Expected redirect to "http://test.host/projects/1/tasks" with status 200, got status 302'
    end

    it 'should set url_matches? message' do
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected redirect to "http://test.host/projects/1/tasks", got redirect to "http://test.host/projects"'
    end
  end

  describe 'matcher' do

    {
      :hash => { :controller => 'tasks', :action => 'index', :project_id => 1 },
      :url =>  'http://test.host/projects/1/tasks',
      :path => '/projects/1/tasks'
    }.each do |type, route|
      describe "redirecting to an #{type}" do 
        before(:each){ build_response { redirect_to route } }

        it { should redirect_to(project_tasks_url(1)) }
        it { should redirect_to(project_tasks_path(1)) }
        it { should redirect_to(:controller => 'tasks', :action => 'index', :project_id => 1) }
        it { should redirect_to(:controller => 'tasks', :action => 'index', :project_id => 1).with(302) }

        it { should_not redirect_to(project_tasks_url(2)) }
        it { should_not redirect_to(project_tasks_path(2)) }
        it { should_not redirect_to(:controller => 'tasks', :action => 'index', :project_id => 2) }
        it { should_not redirect_to(:controller => 'tasks', :action => 'index', :project_id => 1).with(301) }

        it { response.should redirect_to(project_tasks_url(1)) }
        it { response.should redirect_to(project_tasks_path(1)) }
        it { response.should redirect_to(:controller => 'tasks', :action => 'index', :project_id => 1) }
        it { response.should redirect_to(:controller => 'tasks', :action => 'index', :project_id => 1).with(302) }

        it { response.should_not redirect_to(project_tasks_url(2)) }
        it { response.should_not redirect_to(project_tasks_path(2)) }
        it { response.should_not redirect_to(:controller => 'tasks', :action => 'index', :project_id => 2) }
        it { response.should_not redirect_to(:controller => 'tasks', :action => 'index', :project_id => 1).with(301) }
      end
    end

  end

  describe 'macro' do

    {
      :hash => { :controller => 'tasks', :action => 'index', :project_id => 1 },
      :url =>  'http://test.host/projects/1/tasks',
      :path => '/projects/1/tasks'
    }.each do |type, route|
      describe "redirecting to an #{type}" do 
        before(:each){ build_response { redirect_to route } }

        should_redirect_to{ project_tasks_url(1) }
        should_redirect_to{ project_tasks_path(1) }
        should_redirect_to proc{ project_tasks_url(1) }
        should_redirect_to proc{ project_tasks_path(1) }
        should_redirect_to proc{ project_tasks_url(1) }, :with => 302
        should_redirect_to proc{ project_tasks_path(1) }, :with => 302
        should_redirect_to :controller => 'tasks', :action => 'index', :project_id => 1

        should_not_redirect_to{ project_tasks_url(2) }
        should_not_redirect_to{ project_tasks_path(2) }
        should_not_redirect_to proc{ project_tasks_url(2) }
        should_not_redirect_to proc{ project_tasks_path(2) }
        should_not_redirect_to proc{ project_tasks_url(1) }, :with => 301
        should_not_redirect_to proc{ project_tasks_path(1) }, :with => 301
        should_not_redirect_to :controller => 'tasks', :action => 'index', :project_id => 2
      end
    end

  end

  generate_macro_stubs_specs_for(:redirect_to, 'http://google.com/')
end
