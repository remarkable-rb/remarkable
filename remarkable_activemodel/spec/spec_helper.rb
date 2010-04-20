# encoding: utf-8
require 'rubygems'

require 'rspec'

RAILS_VERSION = ENV['RAILS_VERSION'] || '3.0.0.beta3'

gem 'activesupport', RAILS_VERSION
require 'active_support/all'

gem 'activemodel', RAILS_VERSION
require 'active_model'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Load Remarkable core on place to avoid gem to be loaded
dir = File.dirname(__FILE__)
require File.join(dir, '..', '..', 'remarkable', 'lib', 'remarkable')

# Load Remarkable ActiveModel
require File.join(dir, '..', 'lib', 'remarkable_activemodel')

# Include matchers
Remarkable.include_matchers!(Remarkable::ActiveModel, Rspec::Core::ExampleGroup)
