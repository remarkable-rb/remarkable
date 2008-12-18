$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Remarkable
  VERSION = '2.0.0'
end

require File.expand_path(RAILS_ROOT + "/config/environment") if defined?(RAILS_ROOT)
require 'spec'
require 'spec/rails' if defined?(RAILS_ROOT)

require 'remarkable/matcher_base'
require 'remarkable/private_helpers'
require 'remarkable/helpers'
require 'remarkable/assertions'
require 'remarkable/example/example_methods'

require 'remarkable/active_record/active_record' if defined?(ActiveRecord::Base)
require 'remarkable/controller/controller' if defined?(ActionController::Base)
require 'remarkable/rails' if defined?(RAILS_ROOT)
