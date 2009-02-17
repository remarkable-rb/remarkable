$TESTING=true
require File.join(File.dirname(__FILE__), '..', 'lib', 'remarkable-core')

Dir[File.join(File.dirname(__FILE__), 'matchers', '*.rb')].each do |file|
  require file
end

Remarkable.include_matchers!(Remarkable::Specs, Spec::Example::ExampleGroup)
