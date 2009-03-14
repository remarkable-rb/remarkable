require 'rubygems'
require 'spec'
require 'ruby-debug'
require 'active_support'
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
