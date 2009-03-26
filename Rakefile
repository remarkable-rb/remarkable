require "rubygems"
require "fileutils"

include FileUtils

def remarkable_folders
  dir = File.dirname(__FILE__)
  [ File.join(dir, 'remarkable') ] + Dir[ File.join(dir, 'remarkable_*') ]
end

desc "Run spec tasks in all remarkable folders"
task :spec do
  remarkable_folders.each do |folder|
    puts
    cd folder
    system "rake spec"
  end
end

desc "Run pre_commit tasks in all remarkable folders"
task :pre_commit do
  remarkable_folders.each do |folder|
    puts
    cd folder
    system "rake pre_commit"
  end
end

task :default => [:pre_commit]
