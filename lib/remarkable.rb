$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Remarkable
  VERSION = '0.0.99'
end

require "spec"

require 'remarkable/example/example_methods'
require 'remarkable/private_helpers'
require 'remarkable/active_record/active_record'
require 'remarkable/controller/controller'
