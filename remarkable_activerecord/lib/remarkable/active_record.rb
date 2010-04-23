# Load Remarkable
unless Object.const_defined?('Remarkable')
  begin
    require 'remarkable'
  rescue LoadError
    require 'rubygems'
    gem 'remarkable'
    require 'remarkable'
  end
end

# Load Remarkable ActiveRecord files
dir = File.dirname(__FILE__)
require File.join(dir, 'active_record', 'base')

# Add locale
Remarkable.add_locale File.join(dir, '..', '..', 'locale', 'en.yml')

# Add matchers
Dir[File.join(dir, 'active_record', 'matchers', '*.rb')].each do |file|
  require file
end
