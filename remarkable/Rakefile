########### Package && release

PROJECT_SUMMARY     = "Remarkable: a framework for rspec matchers, with support to macros and I18n."
PROJECT_DESCRIPTION = PROJECT_SUMMARY

GEM_NAME   = "remarkable"
GEM_AUTHOR = [ "Carlos Brando", "José Valim" ]
GEM_EMAIL  = [ "eduardobrando@gmail.com", "jose.valim@gmail.com" ]

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
  s.add_dependency('rspec', ">= #{RSPEC_VERSION}")
  s.files = %w(Rakefile) + EXTRA_RDOC_FILES + Dir.glob("{lib,locale,spec}/**/*")
end

Rake::GemPackageTask.new($spec) do |pkg|
  pkg.package_dir = PACKAGE_DIR
  pkg.gem_spec    = $spec
end

########### Specs

desc "Run the specs under spec"
task :pre_commit do
  puts "\n=> #{GEM_NAME}: rake spec"
  Rake::Task[:spec].execute
end
