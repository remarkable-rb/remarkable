require 'rubygems'
require 'ruby-debug'

RAILS_VERSION = '=2.2.2'
RSPEC_VERSION = '=1.1.12'

# Load Rails
gem 'activesupport', RAILS_VERSION
require 'active_support'

gem 'actionpack', RAILS_VERSION
require 'action_controller'

gem 'actionmailer', RAILS_VERSION
require 'action_mailer'

gem 'rails', RAILS_VERSION
require 'rails/version'

# Load Remarkable core on place to avoid gem to be loaded
RAILS_ROOT = dir = File.dirname(__FILE__)
require File.join(dir, '..', '..', 'remarkable', 'lib', 'remarkable')

# Add current path on the load path for application.rb to be loaded
$:.unshift(dir)

# Load Remarkable Rails
require File.join(dir, 'functional_builder')

# Load spec-rails
gem 'rspec-rails', RSPEC_VERSION
require 'spec/rails'

require File.join(dir, '..', 'lib', 'remarkable_rails')

# Register folders to example groups
Spec::Example::ExampleGroupFactory.register(:action_controller, Spec::Rails::Example::ControllerExampleGroup)

