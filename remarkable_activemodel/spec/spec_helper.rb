# encoding: utf-8
require 'rubygems'

require 'rspec'

RAILS_VERSION = ENV['RAILS_VERSION'] || '3.0.0.beta3'

gem 'activesupport', RAILS_VERSION
require 'active_support'

gem 'activerecord', RAILS_VERSION
require 'active_model'

# Configure ActiveModel connection
ActiveModel::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

# Load Remarkable core on place to avoid gem to be loaded
dir = File.dirname(__FILE__)
require File.join(dir, '..', '..', 'remarkable', 'lib', 'remarkable')

# Load Remarkable ActiveModel
require File.join(dir, 'model_builder')
require File.join(dir, '..', 'lib', 'remarkable_activerecord')

# Include matchers
Remarkable.include_matchers!(Remarkable::ActiveModel, Rspec::Core::ExampleGroup)
