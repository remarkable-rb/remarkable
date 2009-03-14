require 'rubygems'
require 'ruby-debug'

# Load spec/rails dependencies
require 'active_support'
require 'action_controller'
require 'action_mailer'

gem 'rails'
require 'rails/version'

# Load Remarkable core on place to avoid gem to be loaded
dir = File.dirname(__FILE__)
require File.join(dir, '..', '..', 'remarkable', 'lib', 'remarkable')

# Add current path on the load path for application.rb to be loaded
$:.unshift(dir)

# Load Remarkable Rails
require File.join(dir, 'functional_builder')
require File.join(dir, '..', 'lib', 'remarkable_rails')

# Register folders to example groups
Spec::Example::ExampleGroupFactory.register(:action_controller, Spec::Rails::Example::ControllerExampleGroup)

