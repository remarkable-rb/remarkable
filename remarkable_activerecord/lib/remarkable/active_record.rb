# Load Remarkable
require 'remarkable/active_model'
require 'remarkable/active_record/base'

# Add default locale
dir = File.dirname(__FILE__)
Dir["#{dir}/../../locale/*yml"].each {|f| Remarkable.add_locale(f) }

# Add matchers
Dir[File.join(dir, 'active_record', 'matchers', '*.rb')].each do |file|
  require file
end

Remarkable.include_matchers!(Remarkable::ActiveRecord, RSpec::Core::ExampleGroup)
