# encoding: utf-8
current_dir = File.dirname(__FILE__)
require File.join(current_dir, "remarkable/lib/remarkable/version.rb")

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'

########### Common package && release

RUBY_FORGE_PROJECT = "remarkable"
PROJECT_URL        = "http://github.com/carlosbrando/remarkable"

GEM_VERSION        = Remarkable::VERSION
PACKAGE_DIR        = File.join(File.dirname(__FILE__), 'pkg')
RELEASE_NAME       = "REL #{GEM_VERSION}"

RSPEC_VERSION      = '2.0.0.alpha7'

def self.configure_gemspec!
  begin
    require 'jeweler'
    Jeweler::Tasks.new do |gemspec|
      gemspec.rubyforge_project = RUBY_FORGE_PROJECT
      gemspec.name = GEM_NAME
      gemspec.version = GEM_VERSION
      gemspec.platform = Gem::Platform::RUBY
      gemspec.has_rdoc = true
      gemspec.extra_rdoc_files = EXTRA_RDOC_FILES
      gemspec.summary = PROJECT_SUMMARY
      gemspec.description = PROJECT_DESCRIPTION
      gemspec.authors = GEM_AUTHOR
      gemspec.email = GEM_EMAIL
      gemspec.homepage = PROJECT_URL
      gemspec.require_path = 'lib'
      gemspec.files = EXTRA_RDOC_FILES + Dir.glob("{lib,locale}/**/*") + Dir.glob("*.gemspec")
      gemspec.add_dependency('rspec', ">= #{RSPEC_VERSION}")
    yield gemspec if block_given?
    end
    Jeweler::GemcutterTasks.new
  rescue LoadError
    puts "Jeweler not available. Install it with: gem install jeweler"
  end
end


########### Common specs

gem 'rspec', ">= #{RSPEC_VERSION}"
# Rspec2
gem 'rspec-expectations'
require 'rspec/core/rake_task'
desc "Run the specs under spec"
Rspec::Core::RakeTask.new do |t|
  # Stub
end


########## Common rdoc

Rake::RDocTask.new do |rdoc|
  rdoc.main     = "README"
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = GEM_NAME
  rdoc.rdoc_files.include(*EXTRA_RDOC_FILES)
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options << '--line-numbers' << '--inline-source'
end

def load_project_path(project)
  project_path = File.join(File.dirname(__FILE__), project, 'lib')
  return nil if $LOAD_PATH.include?(File.expand_path(project_path))
  $LOAD_PATH.unshift(File.expand_path(project_path))
end
