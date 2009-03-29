# How to execute:
#
#   ruby example/specs.rb -rspec_options locale
#
# Examples
#
#   ruby example/specs.rb -fs pt-BR
#   ruby example/specs.rb -fs en
#
# You need rspec >= 1.2.0, rails >= 2.1.2 and sqlite3.

# Get given locale
locale = ARGV.pop

# Load rubygems and rspec
require 'rubygems'
require 'spec'

# Load spec helper
require File.join(File.dirname(__FILE__), '..', 'spec', 'spec_helper')

# Configure remarkable locale
locale_file = File.join(File.dirname(__FILE__), "#{locale}.yml")
Remarkable.add_locale locale_file if File.exist?(locale_file)
Remarkable.locale = locale

# Declaring specs
describe TasksController, :type => :controller do
  should_filter_params :password
  should_not_filter_params :username

  pending('Adicionar admin no sistema') do
    should_filter_params :admin_password
  end

  describe :get => :show, :id => 37 do
    expects :find, :on => Task, :with => '37', :returns => mock_task

    should_assign_to :task, :with => mock_task, :with_kind_of => Task

    describe Mime::XML do
      expects :to_xml, :on => mock_task, :returns => 'generated xml'

      xshould_assign_to :project

      should_assign_to :task, :with => mock_task, :with_kind_of => Task
      should_respond_with :success, :body => /generated xml/
      should_respond_with_content_type Mime::XML
    end
  end

  describe :delete => :destroy, :id => 37 do
    expects :find,    :on => Task,     :with => '37', :returns => mock_task
    expects :destroy, :on => mock_task

    should_assign_to :task, :with => mock_task, :with_kind_of => Task
    should_set_the_flash :notice, :to => 'Task deleted.'
    should_set_session :last_task_id, :to => 37
    should_redirect_to proc{ project_tasks_url(10) }, :with => 302
  end
end

# Run specs
exit ::Spec::Runner::CommandLine.run
