$TESTING=true

require 'rubygems'

dir = File.dirname(__FILE__)
require File.join(dir, '..', 'lib', 'remarkable')

Dir[File.join(dir, 'matchers', '*.rb')].each do |file|
  require file
end

Remarkable.include_matchers!(Remarkable::Specs, Spec::Example::ExampleGroup)

Remarkable.add_locale File.join(dir, 'locale', 'en.yml')
Remarkable.add_locale File.join(dir, 'locale', 'pt-BR.yml')
