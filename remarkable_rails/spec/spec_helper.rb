require 'rubygems'
require 'ruby-debug'

# Load spec/rails dependencies
require 'active_support'

gem 'rails'
require 'rails/version'
require 'action_controller'
require 'action_mailer'

# Load Remarkable core on place to avoid gem to be loaded
dir = File.dirname(__FILE__)
require File.join(dir, '..', '..', 'remarkable', 'lib', 'remarkable')

# Add current path on the load path for application.rb to be loaded
$:.unshift(dir)

# Load Remarkable Rails
require File.join(dir, 'functional_builder')
require File.join(dir, '..', 'lib', 'remarkable_rails')

# Define routes
ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format' 
end

# Include matchers
Remarkable.include_matchers!(Remarkable::ActionController, Spec::Example::ExampleGroup)
