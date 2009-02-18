# This is a wrapper for I18n default functionality
module Remarkable
  module I18n

    # Add locale files to I18n
    def add_locale(*locales)
      ::I18n.backend.load_translations *locales
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
      ::I18n.t string, { :locale => @@locale }.merge(options)
    end
    alias :t :translate

    # Wrapper for localization
    def localize(object, options = {})
      ::I18n.l object, { :locale => @@locale }.merge(options)
    end
    alias :l :localize

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

  # Set default locale
  I18n.default_locale = :en
end

# Add module to Remarkable
Remarkable.send :extend, Remarkable::I18n

# Set Remarkable locale
Remarkable.locale = I18n.locale

# Add Remarkable default locale file
Remarkable.add_locale File.join(File.dirname(__FILE__), '..', '..', 'locale', 'en.yml')

# Hacks into Spec to provide I18n
module Spec
  module Matchers
    def self.generated_description
      return nil if last_should.nil?
      verb = Remarkable.t "remarkable.core.#{last_should}", :default => last_should.to_s.gsub('_',' ')
      "#{verb} #{last_description}"
    end
  end

  module Example
    module ExampleGroupMethods
      def xexample(description=nil, opts={}, &block)
        disabled = Remarkable.t 'remarkable.core.example_disabled', :default => 'Example disabled'
        Kernel.warn("#{disabled}: #{description}")
      end
      alias_method :xit, :xexample
      alias_method :xspecify, :xexample
    end
  end
end
