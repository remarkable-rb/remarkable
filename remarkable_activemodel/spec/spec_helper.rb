# encoding: utf-8
require 'rubygems'
require 'rspec'
require 'active_support/all'
require 'active_model'

require File.expand_path('path_helpers', File.join(File.dirname(__FILE__), '/../../'))
load_project_path :remarkable, :remarkable_activemodel

require 'remarkable/active_model'

# Requires supporting files with custom matchers and macros, etc,
# # in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
