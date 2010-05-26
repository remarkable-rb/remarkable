# encoding: utf-8
require 'rubygems'
require 'rspec'

RAILS_VERSION = ENV['RAILS_VERSION'] || '3.0.0.beta3'

gem 'activesupport', RAILS_VERSION
require 'active_support'

gem 'activerecord', RAILS_VERSION
require 'active_record'

require File.expand_path('path_helpers', File.join(File.dirname(__FILE__), '/../../'))
load_project_path :remarkable, :remarkable_activemodel, :remarkable_activerecord

require 'remarkable/active_record'

# Configure ActiveRecord connection
ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
