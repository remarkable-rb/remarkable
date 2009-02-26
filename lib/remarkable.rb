$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Remarkable
  VERSION = '2.2.7'
end

if ENV['RAILS_ENV'] == 'test'
  require 'spec/rails'
end

require 'remarkable/dsl'
require 'remarkable/matcher_base'
require 'remarkable/private_helpers'
require 'remarkable/helpers'
require 'remarkable/assertions'
require 'remarkable/example/example_methods'

require 'remarkable/active_record/active_record' if defined?(ActiveRecord::Base)
require 'remarkable/controller/controller' if defined?(ActionController::Base)
require 'remarkable/rails' if defined?(RAILS_ROOT)
