
# Load Remarkable ActiveRecord files
dir = File.dirname(__FILE__)
require File.join(dir, 'remarkable', 'active_record')

Remarkable.include_matchers!(Remarkable::ActiveRecord, Rspec::Core::ExampleGroup)
