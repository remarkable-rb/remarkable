require 'rubygems'
require 'ruby-debug'

dir = File.dirname(__FILE__)
FIXTURE_PATH = File.join(dir, "fixtures")
require File.join(dir, '..', '..', 'remarkable_rails', 'spec', 'rails_loader_helper')

rails_load! do
  # Load Remarkable ActiveRecord
  require File.join(dir, '..', 'lib', 'remarkable_activerecord')
end
