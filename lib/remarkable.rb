$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Remarkable
  VERSION = '1.1.1'
end

require "spec"

require 'remarkable/example/example_methods'
require 'remarkable/private_helpers'
require 'remarkable/active_record/active_record' if defined?(ActiveRecord::Base)
require 'remarkable/controller/controller' if defined?(ActionController::Base)
require 'remarkable/rails' if defined?(RAILS_ROOT)
