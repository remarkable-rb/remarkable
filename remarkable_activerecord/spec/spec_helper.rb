require 'rubygems'
require 'ruby-debug'

RAILS_VERSION = ENV['RAILS_VERSION'] || '=2.2.2'

gem 'activesupport', RAILS_VERSION
require 'active_support'

gem 'activerecord', RAILS_VERSION
require 'active_record'

# Configure ActiveRecord connection
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile  => 'memory'
)

# Load Remarkable core on place to avoid gem to be loaded
dir = File.dirname(__FILE__)
require File.join(dir, '..', '..', 'remarkable', 'lib', 'remarkable')

# Load Remarkable ActiveRecord
require File.join(dir, 'model_builder')
require File.join(dir, '..', 'lib', 'remarkable_activerecord')

# Include matchers
Remarkable.include_matchers!(Remarkable::ActiveRecord, Spec::Example::ExampleGroup)
