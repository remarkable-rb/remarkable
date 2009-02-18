dir = File.dirname(__FILE__)

module Remarkable
  # Helper that includes required Remarkable modules into the given klass.
  def self.include_matchers!(base, klass)
    # Add Remarkable core modules
    klass.send :extend,  Remarkable::Macros

    klass.send :include, base::Matchers if defined?(base::Matchers)
    klass.send :extend,  base::Matchers if defined?(base::Matchers)
    klass.send :extend,  base::Macros   if defined?(base::Macros)
  end

  # Add locale files to I18n
  def self.add_locale(*locales)
    I18n.backend.load_translations *locales
  end
end

# Load I18n
unless Object.const_defined?('I18n')
  begin
    require 'i18n'
  rescue Exception => e
    require 'rubygems'
    # TODO Move to i18n gem as soon as it gets updated
    gem 'josevalim-i18n'
    require 'i18n'
  end
end

# Add Remarkable default locale file
Remarkable.add_locale File.join(dir, '..', 'locale', 'en.yml')

# Load core files
require File.join(dir, 'remarkable_core', 'version')
require File.join(dir, 'remarkable_core', 'core_ext', 'array')
require File.join(dir, 'remarkable_core', 'dsl')
require File.join(dir, 'remarkable_core', 'base')
require File.join(dir, 'remarkable_core', 'macros')
