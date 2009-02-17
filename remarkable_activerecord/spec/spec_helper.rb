begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

RAILS_ROOT = File.dirname(__FILE__) + '/rails_root'
require "#{RAILS_ROOT}/config/environment.rb"

silence_warnings { RAILS_ENV = ENV['RAILS_ENV'] }

ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{RAILS_ROOT}/db/migrate")

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures  = false
  config.fixture_path = File.join(File.dirname(__FILE__), "fixtures")
end