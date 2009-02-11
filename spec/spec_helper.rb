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

def create_table(table_name, &block)
  connection = ActiveRecord::Base.connection
  
  begin
    connection.execute("DROP TABLE IF EXISTS #{table_name}")
    connection.create_table(table_name, &block)
    @created_tables ||= []
    @created_tables << table_name
    connection
  rescue Exception => e
    connection.execute("DROP TABLE IF EXISTS #{table_name}")
    raise e
  end
end

def define_model_class(class_name, &block)
  klass = Class.new(ActiveRecord::Base)
  Object.const_set(class_name, klass)

  klass.class_eval(&block) if block_given?

  @defined_constants ||= []
  @defined_constants << class_name

  klass
end

def define_model(name, columns = {}, &block)
  class_name = name.to_s.pluralize.classify
  table_name = class_name.tableize

  create_table(table_name) do |table|
    columns.each do |name, type|
      table.column name, type
    end
  end

  define_model_class(class_name, &block)
end
