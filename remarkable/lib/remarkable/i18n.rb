# This is a wrapper for I18n default functionality
module Remarkable
  module I18n

    # Add locale files to I18n and to load path, if it exists.
    def add_locale(*locales)
      ::I18n.backend.load_translations *locales
      ::I18n.load_path += locales if ::I18n.respond_to?(:load_path)
    end

    # Set Remarkable locale (which is not necessarily the same as the application)
    def locale=(locale)
      @@locale = locale
    end

    # Get Remarkable locale (which is not necessarily the same as the application)
    def locale
      @@locale
    end

    # Wrapper for translation
    def translate(string, options = {})
      ::I18n.translate string, { :locale => @@locale }.merge(options)
    end
    alias :t :translate

    # Wrapper for localization
    def localize(object, options = {})
      ::I18n.localize object, { :locale => @@locale }.merge(options)
    end
    alias :l :localize

  end
end

# Load I18n
RAILS_I18N = Object.const_defined?('I18n') # Rails >= 2.2

unless RAILS_I18N
  begin
    require 'i18n'
  rescue LoadError
    require 'rubygems'
    # TODO Move to i18n gem as soon as it gets updated
    gem 'josevalim-i18n'
    require 'i18n'
  end

  # Set default locale
  ::I18n.default_locale = :en
end

Remarkable.extend Remarkable::I18n
Remarkable.locale = I18n.locale
