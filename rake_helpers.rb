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

RSPEC_VERSION      = '1.2.0'

def self.configure_gemspec!
  $spec = Gem::Specification.new do |s|
    s.rubyforge_project = RUBY_FORGE_PROJECT
    s.name = GEM_NAME
    s.version = GEM_VERSION
    s.platform = Gem::Platform::RUBY
    s.has_rdoc = true
    s.extra_rdoc_files = EXTRA_RDOC_FILES
    s.summary = PROJECT_SUMMARY
    s.description = PROJECT_DESCRIPTION
    s.authors = GEM_AUTHOR
    s.email = GEM_EMAIL
    s.homepage = PROJECT_URL
    s.require_path = 'lib'
    s.files = EXTRA_RDOC_FILES + Dir.glob("{lib,locale}/**/*") + Dir.glob("*.gemspec")
    s.add_dependency('rspec', ">= #{RSPEC_VERSION}")
    yield s if block_given?
  end

  Rake::GemPackageTask.new($spec) do |pkg|
    pkg.package_dir = PACKAGE_DIR
    pkg.gem_spec    = $spec
    pkg.need_zip    = true
    pkg.need_tar    = true
  end
end

desc "Create a gemspec file"
task :gemspec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts $spec.to_ruby
  end
end

desc "Build the gem and install it"
task :install => :gem do
  system("sudo gem install #{PACKAGE_DIR}/#{GEM_NAME}-#{GEM_VERSION}.gem --local --ignore-dependencies --no-ri --no-rdoc")
end

desc "Uninstall the gem"
task :uninstall do
  system("sudo gem uninstall #{GEM_NAME} --version #{GEM_VERSION}")
end

########### Common specs

gem 'rspec'
require 'spec/rake/spectask'

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
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
