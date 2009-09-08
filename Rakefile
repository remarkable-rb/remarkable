# encoding: utf-8
current_dir = File.dirname(__FILE__)
require File.join(current_dir, "remarkable/lib/remarkable/version.rb")

require "rubygems"
require "fileutils"
include FileUtils

REMARKABLE_GEMS = [
  :remarkable,
  :remarkable_activerecord,
  # :remarkable_datamapper,
  :remarkable_rails
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
                :rdoc, :repackage, :rerdoc, :spec, :uninstall

desc "Default Task"
task :default do
  Rake::Task[:spec].execute
end

desc "Publish release files to RubyForge"
task :release => :package do
  require 'rubyforge'

  r = RubyForge.new
  r.configure

  puts "Logging in..."
  r.login

  REMARKABLE_GEMS.each do |gem|
    packages = %w(gem tgz zip).collect{ |ext| File.join(PACKAGE_DIR, "#{gem}-#{GEM_VERSION}.#{ext}") }

    begin
      puts "Adding #{gem} #{GEM_VERSION}..."
      r.add_release RUBY_FORGE_PROJECT, gem.to_s, GEM_VERSION, *packages
      packages.each{|p| r.add_file(RUBY_FORGE_PROJECT, gem.to_s, GEM_VERSION, p) }
    rescue Exception => e
      if e.message =~ /You have already released this version/
        puts "You already released #{gem}-#{GEM_VERSION}. Continuing..."
        puts
      else
        raise e
      end
    end
  end
end
