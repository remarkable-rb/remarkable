$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Remarkable
  VERSION = '1.0.0'
end

require "spec"

require 'remarkable/example/example_methods'
require 'remarkable/private_helpers'
require 'remarkable/active_record/active_record'
require 'remarkable/controller/controller'
