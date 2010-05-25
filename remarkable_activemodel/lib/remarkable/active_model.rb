# Load Remarkable
require 'remarkable/core'
require 'remarkable/active_model/base'

# Add default locale
dir = File.dirname(__FILE__)
Dir["#{dir}/../../locale/*yml"].each {|f| Remarkable.add_locale(f) }

# Add matchers
Dir[File.join(dir, 'active_model', 'matchers', '*.rb')].each do |file|
  require file
end

Remarkable.include_matchers!(Remarkable::ActiveModel, Rspec::Core::ExampleGroup)
