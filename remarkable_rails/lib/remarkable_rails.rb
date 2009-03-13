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

# Load Remarkable Rails files
dir = File.dirname(__FILE__)
require File.join(dir, 'remarkable_rails', 'active_orm')
require File.join(dir, 'remarkable_rails', 'base')

# Load matchers
Dir[File.join(dir, 'remarkable_rails', 'action_*', '*.rb')].each do |file|
  require file
end

# Load locale file
Remarkable.add_locale File.join(dir, '..', 'locale', 'en.yml')

# Load spec/rails and include matchers in spec
if defined?(Spec)
  begin
    require 'spec/rails'
  rescue LoadError
    require 'rubygems'
    gem 'rspec-rails'
    require 'spec/rails'
  end

  Remarkable.include_matchers!(Remarkable::ActionController, Spec::Rails::Example::FunctionalExampleGroup)
end
