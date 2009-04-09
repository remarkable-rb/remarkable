require File.join(File.dirname(__FILE__), "..", "remarkable", "lib", "remarkable", "version.rb")
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'

########### Package && release

RUBY_FORGE_PROJECT = "remarkable"
PROJECT_URL        = "http://github.com/carlosbrando/remarkable"
PROJECT_SUMMARY    = "Remarkable ActiveRecord: collection of matchers and macros with I18n for ActiveRecord"
PROJECT_DESCRIPTION = PROJECT_SUMMARY

GEM_AUTHOR = [ "Carlos Brando", "José Valim", "Diego Carrion" ]
GEM_EMAIL  = [ "eduardobrando@gmail.com", "jose.valim@gmail.com", "dc.rec1@gmail.com" ]

GEM_NAME    = "remarkable_activerecord"
GEM_VERSION = Remarkable::VERSION

PACKAGE_DIR  = File.join(File.dirname(__FILE__), '..', 'pkg')
RELEASE_NAME = "REL #{GEM_VERSION}"

EXTRA_RDOC_FILES = ["README", "LICENSE", "CHANGELOG"]

spec = Gem::Specification.new do |s|
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
  s.add_dependency('remarkable', ">= #{GEM_VERSION}")
  s.files = %w(Rakefile) + EXTRA_RDOC_FILES + Dir.glob("{lib,locale,spec}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.package_dir = PACKAGE_DIR
  pkg.gem_spec    = spec
end

desc "Create a gemspec file"
task :gemspec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "Build the gem and install it"
task :install => :gem do
  system("sudo gem install #{PACKAGE_DIR}/#{GEM_NAME}-#{GEM_VERSION}.gem --local --ignore-dependencies")
end

desc "Uninstall the gem"
task :uninstall do
  system("sudo gem uninstall #{GEM_NAME} --version #{GEM_VERSION}")
end

########### Specs

gem 'rspec', ENV['RSPEC_VERSION'] || '1.2.2'
require 'spec/rake/spectask'

RAILS_VERSIONS = ['2.1.2', '2.2.2', '2.3.2']

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Run the specs under spec with supported Rails versions"
task :pre_commit do
  RAILS_VERSIONS.each do |version|
    ENV['RAILS_VERSION'] = version
    puts "\n=> #{GEM_NAME}: rake spec RAILS_VERSION=#{version}"
    Rake::Task[:spec].execute
  end
end

########### RDoc

Rake::RDocTask.new do |rdoc|
  rdoc.main     = "README"
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = GEM_NAME
  rdoc.rdoc_files.include(*EXTRA_RDOC_FILES)
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options << '--line-numbers' << '--inline-source'
end
