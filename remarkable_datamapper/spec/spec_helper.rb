# encoding: utf-8
require 'rubygems'

DM_VERSION = '0.10.0'

# TODO Remove ActiveSupport dependence
gem 'activesupport', '2.3.4'
require 'active_support'

gem 'addressable'
require 'addressable/uri'

gem 'data_objects', DM_VERSION
require 'data_objects'

gem 'do_sqlite3', DM_VERSION
require 'do_sqlite3'

gem 'dm-core', DM_VERSION
require 'dm-core'

gem 'dm-validations', DM_VERSION
require 'dm-validations'

# Require i18n by hand
gem 'i18n'
require 'i18n'

ENV['SQLITE3_SPEC_URI'] ||= 'sqlite3::memory:'
ENV['ADAPTER'] = 'sqlite3'

# Configure DataMapper Adapter
def setup_adapter(name, default_uri = nil)
  begin
    DataMapper.setup(name, ENV["#{ENV['ADAPTER'].to_s.upcase}_SPEC_URI"] || default_uri)
    Object.const_set('ADAPTER', ENV['ADAPTER'].to_sym) if name.to_s == ENV['ADAPTER']
    true
  rescue Exception => e
    if name.to_s == ENV['ADAPTER']
      Object.const_set('ADAPTER', nil)
      warn "Could not load do_#{name}: #{e}"
    end
    false
  end
end

setup_adapter(:default)

# Load Remarkable core on place to avoid gem to be loaded
dir = File.dirname(__FILE__)
require File.join(dir, '..', '..', 'remarkable', 'lib', 'remarkable')

# Load Remarkable DataMapper
require File.join(dir, 'model_builder')
require File.join(dir, '..', 'lib', 'remarkable_datamapper')

# Include matchers
Remarkable.include_matchers!(Remarkable::DataMapper, Spec::Example::ExampleGroup)
