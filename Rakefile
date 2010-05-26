# encoding: utf-8
current_dir = File.dirname(__FILE__)
require File.join(current_dir, "remarkable/lib/remarkable/core/version.rb")

require "rubygems"
require "fileutils"
include FileUtils

REMARKABLE_GEMS = [
  :remarkable,
  :remarkable_activemodel,
  :remarkable_activerecord,
  #:remarkable_datamapper,
  #:remarkable_rails
]

REMARKABLE_GEMS_PATHS = REMARKABLE_GEMS.map{|g| File.join(current_dir, g.to_s)}

RUBY_FORGE_PROJECT = "remarkable"
GEM_VERSION        = Remarkable::VERSION
PACKAGE_DIR        = File.join(File.dirname(__FILE__), 'pkg')

# Create tasks that are called inside remarkable path
def self.unique_tasks(*names)
  names.each do |name|
    desc "Run #{name} tasks in remarkable core gem"
    task name do
      cd REMARKABLE_GEMS_PATHS[0]
      system "rake #{name}"
    end
  end
end

# Create tasks that are called in each path
def self.recursive_tasks(*names)
  names.each do |name|
    desc "Run #{name} tasks in all remarkable gems"
    task name do
      REMARKABLE_GEMS_PATHS.each do |path|
        cd path
        system "rake #{name}"
        puts
      end
    end
  end
end

unique_tasks    :clobber_package
recursive_tasks :clobber_rdoc, :gem, :gemspec, :install, :package, :pre_commit,
                :rdoc, :repackage, :rerdoc, :spec, :uninstall, :build

desc "Default Task"
task :default do
  Rake::Task[:spec].execute
end

desc "Publish release files to RubyForge"
task :release => [:gemspec, :package] do
  REMARKABLE_GEMS.each do |gem|
    path    = File.join(PACKAGE_DIR, "#{gem}-#{GEM_VERSION}.gem")
    command = "gem push #{path}"

    puts command
    system command
  end
end
