# encoding: utf-8
PROJECT_SUMMARY     = "Remarkable DataMapper: collection of matchers and macros with I18n for DataMapper"
PROJECT_DESCRIPTION = PROJECT_SUMMARY

GEM_NAME   = "remarkable_datamapper"
GEM_AUTHOR = [ "Blake Gentry", "José Valim" ]
GEM_EMAIL  = [ "blakesgentry@gmail.com", "jose.valim@gmail.com" ]

EXTRA_RDOC_FILES = ["README", "LICENSE", "CHANGELOG"]

require File.join(File.dirname(__FILE__), "..", "rake_helpers.rb")

########### Package && release

configure_gemspec! do |s|
  s.add_dependency('remarkable', "~> #{GEM_VERSION}")
end

########### Specs

desc "Run the specs under spec"
task :pre_commit do
  puts "\n=> #{GEM_NAME}: rake spec"
  Rake::Task[:spec].execute
end
