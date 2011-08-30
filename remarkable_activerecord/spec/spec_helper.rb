# encoding: utf-8
require 'rubygems'
require 'rspec'
require 'active_support'
require 'active_record'

require File.expand_path('path_helpers', File.join(File.dirname(__FILE__), '/../../'))
load_project_path :remarkable, :remarkable_activemodel, :remarkable_activerecord

require 'remarkable/active_record'

# USAGE:
#   model.something.to_watch.tap(&WATCH)
require 'ap'
WATCH = lambda { |x| ap x }

# Configure ActiveRecord connection
ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run :focus => true
  config.filter_run_excluding :external => true
  config.run_all_when_everything_filtered = true 
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
