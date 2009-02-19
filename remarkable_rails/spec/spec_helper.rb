require 'rubygems'
require 'ruby-debug'

dir = File.dirname(__FILE__)
FIXTURE_PATH = File.join(dir, "fixtures")
require dir + '/rails_loader_helper'

rails_load!
