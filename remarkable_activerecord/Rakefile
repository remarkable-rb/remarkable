# encoding: utf-8
PROJECT_SUMMARY     = "Remarkable ActiveRecord: collection of matchers and macros with I18n for ActiveRecord"
PROJECT_DESCRIPTION = PROJECT_SUMMARY

GEM_NAME   = "remarkable_activerecord"
GEM_AUTHOR = [ "Ho-Sheng Hsiao", "Carlos Brando", "José Valim", "Diego Carrion" ]
GEM_EMAIL  = [ "hosh@sparkfly.com", "eduardobrando@gmail.com", "jose.valim@gmail.com", "dc.rec1@gmail.com" ]

EXTRA_RDOC_FILES = ["README", "LICENSE", "CHANGELOG"]

require File.join(File.dirname(__FILE__), "..", "rake_helpers.rb")

########### Package && release

configure_gemspec! do |s|
  s.add_dependency('remarkable', "~> #{GEM_VERSION}")
  s.add_dependency('remarkable_activemodel', "~> #{GEM_VERSION}")
end

########### Specs

desc "Run the specs under spec with supported Rails versions"
task :pre_commit do
  puts "\n=> #{GEM_NAME}: rake spec"
  Rake::Task[:spec].execute
end
