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

desc "Create a gemspec file"
task :gemspec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts $spec.to_ruby
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

########### Common specs

gem 'rspec', ENV['RSPEC_VERSION'] || '1.2.2'
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
