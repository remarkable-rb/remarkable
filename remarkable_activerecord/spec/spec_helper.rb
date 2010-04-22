# encoding: utf-8
require 'rubygems'

require 'rspec'

RAILS_VERSION = ENV['RAILS_VERSION'] || '3.0.0.beta3'

gem 'activesupport', RAILS_VERSION
require 'active_support'

gem 'activerecord', RAILS_VERSION
require 'active_record'

# Configure ActiveRecord connection
ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Load Remarkable core on place to avoid gem to be loaded
dir = File.dirname(__FILE__)
require File.join(dir, '..', '..', 'remarkable', 'lib', 'remarkable')
require File.join(dir, '..', '..', 'remarkable_activemodel', 'lib', 'remarkable_activemodel')
#
# Load Remarkable ActiveRecord
require File.join(dir, '..', 'lib', 'remarkable_activerecord')

# Include matchers
Remarkable.include_matchers!(Remarkable::ActiveModel, Rspec::Core::ExampleGroup)
Remarkable.include_matchers!(Remarkable::ActiveRecord, Rspec::Core::ExampleGroup)
