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

# Load spec/rails
if defined?(Spec)
  begin
    require 'spec/rails'
  rescue LoadError
    require 'rubygems'
    gem 'rspec-rails'
    require 'spec/rails'
  end
end

# Load Remarkable Rails base files
dir = File.dirname(__FILE__)
require File.join(dir, 'remarkable_rails', 'active_orm')
require File.join(dir, 'remarkable_rails', 'action_controller')
require File.join(dir, 'remarkable_rails', 'action_view')

# Load locale file
Remarkable.add_locale File.join(dir, '..', 'locale', 'en.yml')
