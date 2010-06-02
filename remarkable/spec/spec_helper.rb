$TESTING=true

require 'rubygems'
require 'rspec'

require File.expand_path('path_helpers', File.join(File.dirname(__FILE__), '/../../'))
load_project_path :remarkable

require 'remarkable/core'

# Requires supporting files with custom matchers and macros, etc,
# # in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Load custom matchers
Remarkable.include_matchers!(Remarkable::RSpec, RSpec::Core::ExampleGroup)

# Load custom locales
Dir["#{File.dirname(__FILE__)}/support/locale/*yml"].each {|f| Remarkable.add_locale(f) }
