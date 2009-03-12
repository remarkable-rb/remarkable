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

# Load rspec-rails if rspec is defined.
if defined?(Spec)
  begin
    require 'spec/rails'
  rescue LoadError
    require 'rubygems'
    gem 'rspec-rails'
    require 'spec/rails'
  end
end

# Load Remarkable Rails files
dir = File.dirname(__FILE__)
require File.join(dir, 'remarkable_rails', 'active_orm')
require File.join(dir, 'remarkable_rails', 'base')

# Include ActionController matchers
Dir[File.join(dir, 'remarkable_rails', 'action_controller', '*.rb')].each do |file|
  require file
end
Remarkable.include_matchers!(Remarkable::ActionController, Spec::Rails::Example::FunctionalExampleGroup)

# Include ActionView matchers
# Dir[File.join(dir, 'remarkable_rails', 'action_view', '*.rb')].each do |file|
#   require file
# end
# Remarkable.include_matchers!(Remarkable::ActionController, Spec::Rails::Example::RailsExampleGroup)

Remarkable.add_locale File.join(dir, '..', 'locale', 'en.yml')
