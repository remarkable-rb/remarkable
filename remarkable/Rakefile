# encoding: utf-8
PROJECT_SUMMARY     = "Remarkable: a framework for rspec matchers, with support to macros and I18n."
PROJECT_DESCRIPTION = PROJECT_SUMMARY

GEM_NAME   = "remarkable"
GEM_AUTHOR = [ "Carlos Brando", "José Valim" ]
GEM_EMAIL  = [ "eduardobrando@gmail.com", "jose.valim@gmail.com" ]

EXTRA_RDOC_FILES = ["README", "LICENSE", "CHANGELOG"]

require File.join(File.dirname(__FILE__), "..", "rake_helpers.rb")

########### Package && release

configure_gemspec!

########### Specs

desc "Run the specs under spec"
task :pre_commit do
  puts "\n=> #{GEM_NAME}: rake spec"
  Rake::Task[:spec].execute
end
