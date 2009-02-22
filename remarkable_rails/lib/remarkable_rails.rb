# Load Remarkable (whick loads rspec)
unless Object.const_defined?('Remarkable')
  begin
    require 'remarkable'
  rescue LoadError
    require 'rubygems'
    gem 'remarkable'
    require 'remarkable'
  end
end

# Load rspec-rails
begin
  require 'spec/rails'
rescue LoadError
  require 'rubygems'
  gem 'rspec-rails'
  require 'spec/rails'
end

# Load Remarkable Rails files
dir = File.dirname(__FILE__)
require File.join(dir, 'remarkable_rails', 'active_orm')
