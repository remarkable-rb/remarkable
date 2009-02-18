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

# Add Remarkable default locale file
Remarkable.add_locale File.join(File.dirname(__FILE__), '..', '..', 'locale', 'en.yml')

# Hacks into Spec::Matcher to provide i18n
module Spec
  module Matchers
    def self.generated_description
      return nil if last_should.nil?
      verb = I18n.t "remarkable.core.#{last_should}", :default => last_should.to_s.gsub('_',' ')
      "#{verb} #{last_description}"
    end
  end
end
