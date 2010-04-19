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

# Load Remarkable ActiveModel files
dir = File.dirname(__FILE__)
require File.join(dir, 'remarkable_activerecord', 'base')
require File.join(dir, 'remarkable_activerecord', 'describe')
require File.join(dir, 'remarkable_activerecord', 'human_names')

# Add locale
Remarkable.add_locale File.join(dir, '..', 'locale', 'en.yml')

# Add matchers
Dir[File.join(dir, 'remarkable_activerecord', 'matchers', '*.rb')].each do |file|
  require file
end

# By default, ActiveModel matchers are not included in any example group.
# The responsibility for this is RemarkableRails. If you are using ActiveModel
# without Rails, put the line below in your spec_helper to include ActiveModel
# matchers into rspec globally.
# Remarkable.include_matchers!(Remarkable::ActiveModel, Rspec::Example::ExampleGroup)
