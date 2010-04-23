# Load Remarkable ActiveModel files
dir = File.dirname(__FILE__)
require File.join(dir, 'remarkable', 'active_model')

Remarkable.include_matchers!(Remarkable::ActiveModel, Rspec::Core::ExampleGroup)
