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

# Load ActiveRecord matchers
if defined?(ActiveRecord::Base)
  unless Remarkable.const_defined?('ActiveRecord')
    begin
      require 'remarkable_activerecord'
    rescue LoadError
      require 'rubygems'
      gem 'remarkable_activerecord'
      require 'remarkable_activerecord'
    end
  end

  # Include Remarkable ActiveRecord matcher in appropriate ExampleGroup
  Remarkable.include_matchers!(Remarkable::ActiveRecord, Spec::Rails::Example::ModelExampleGroup)
end

module Remarkable
  module Rails
  end
end

# Load Remarkable Rails files
dir = File.dirname(__FILE__)

