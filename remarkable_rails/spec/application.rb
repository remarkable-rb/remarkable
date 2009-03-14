# Create an application controller to satisfy rspec-rails, a dummy controller
# and define routes.
#
class ApplicationController < ActionController::Base
end

class Task; end
class TasksController < ApplicationController
  def index
    @tasks = Task.find(:all)
    render :text => 'index'
  end

  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html { render :text => 'show' }
      format.xml  { render :xml => @task.to_xml }
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
     format.html { redirect_to project_tasks_url(10) }
     format.xml  { head :ok }
    end
  end
end

# Define routes
ActionController::Routing::Routes.draw do |map|
  map.resources :projects, :has_many => :tasks
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

