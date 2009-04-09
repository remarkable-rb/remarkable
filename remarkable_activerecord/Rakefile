########### Package && release

PROJECT_SUMMARY     = "Remarkable ActiveRecord: collection of matchers and macros with I18n for ActiveRecord"
PROJECT_DESCRIPTION = PROJECT_SUMMARY

GEM_NAME   = "remarkable_activerecord"
GEM_AUTHOR = [ "Carlos Brando", "José Valim", "Diego Carrion" ]
GEM_EMAIL  = [ "eduardobrando@gmail.com", "jose.valim@gmail.com", "dc.rec1@gmail.com" ]

EXTRA_RDOC_FILES = ["README", "LICENSE", "CHANGELOG"]

require File.join(File.dirname(__FILE__), "..", "rake_helpers.rb")

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
  s.add_dependency('remarkable', ">= #{GEM_VERSION}")
  s.files = %w(Rakefile) + EXTRA_RDOC_FILES + Dir.glob("{lib,locale,spec}/**/*")
end

Rake::GemPackageTask.new($spec) do |pkg|
  pkg.package_dir = PACKAGE_DIR
  pkg.gem_spec    = $spec
end

########### Specs

RAILS_VERSIONS = ['2.1.2', '2.2.2', '2.3.2']

desc "Run the specs under spec with supported Rails versions"
task :pre_commit do
  RAILS_VERSIONS.each do |version|
    ENV['RAILS_VERSION'] = version
    puts "\n=> #{GEM_NAME}: rake spec RAILS_VERSION=#{version}"
    Rake::Task[:spec].execute
  end
end
