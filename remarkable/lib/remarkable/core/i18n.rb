module Remarkable
  # This is a wrapper for I18n default functionality.
  #
  # Remarkable shouldn't rely on I18n default locale, because it might change
  # throughout tests. So it's Remarkable responsibility to hold its own locale
  # and send it to I18n.
  #
  module I18n

    # Add locale files to I18n and to load path, if it exists.
    #
    # == Examples
    #
    #   Remarkable.add_locale "path/to/locale"
    #
    def add_locale(*locales)
      ::I18n.backend.load_translations *locales
      ::I18n.load_path += locales if ::I18n.respond_to?(:load_path)
    end

    # Set Remarkable own locale.
    #
    # == Examples
    #
    #   Remarkable.locale = :en
    #
    def locale=(locale)
      @@locale = locale
    end

    # Get Remarkable own locale.
    #
    # == Examples
    #
    #   Remarkable.locale = :en
    #   Remarkable.locale #=> :en
    #
    def locale
      @@locale
    end

    # Wrapper for I18n.translate
    #
    def translate(string, options = {})
      ::I18n.translate string, { :locale => @@locale }.merge(options)
    end
    alias :t :translate

    # Wrapper for I18n.localize
    #
    def localize(object, options = {})
      ::I18n.localize object, { :locale => @@locale }.merge(options)
    end
    alias :l :localize

  end
end

# Load I18n
RAILS_I18N = Object.const_defined?(:I18n) unless Object.const_defined?(:RAILS_I18N) # Rails >= 2.2

unless RAILS_I18N
  begin
    require 'i18n'
  rescue LoadError
    require 'rubygems'
    gem 'i18n'
    require 'i18n'
  end

  # Set default locale
  ::I18n.default_locale = :en
end

Remarkable.extend Remarkable::I18n
Remarkable.locale = :en
