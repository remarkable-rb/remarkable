# encoding: utf-8
PROJECT_SUMMARY     = "Remarkable Rails: collection of matchers and macros with I18n for Rails"
PROJECT_DESCRIPTION = PROJECT_SUMMARY

GEM_NAME   = "remarkable_rails"
GEM_AUTHOR = [ "Carlos Brando", "José Valim" ]
GEM_EMAIL  = [ "eduardobrando@gmail.com", "jose.valim@gmail.com" ]

EXTRA_RDOC_FILES = ["README", "LICENSE", "CHANGELOG"]

require File.join(File.dirname(__FILE__), "..", "rake_helpers.rb")

########### Package && release

configure_gemspec! do |s|
  s.add_dependency('rspec-rails', ">= #{RSPEC_VERSION}")
  s.add_dependency('remarkable', "~> #{GEM_VERSION}")
  s.add_dependency('remarkable_activerecord', "~> #{GEM_VERSION}")
end

########### Specs

RAILS_VERSIONS = ['2.2.2', '2.3.4', '2.3.5']

desc "Run the specs under spec with supported Rails versions"
task :pre_commit do
  RAILS_VERSIONS.each do |version|
    ENV['RAILS_VERSION'] = version
    puts "\n=> #{GEM_NAME}: rake spec RAILS_VERSION=#{version}"
    Rake::Task[:spec].execute
  end
end
