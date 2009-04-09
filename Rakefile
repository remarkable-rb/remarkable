current_dir = File.dirname(__FILE__)
require File.join(current_dir, "remarkable/lib/remarkable/version.rb")

require "rubygems"
require "fileutils"

include FileUtils

remarkable_gems = [
  :remarkable,
  :remarkable_activerecord,
  :remarkable_rails
]

remarkable_gems_paths = remarkable_gems.map{|g| File.join(current_dir, g.to_s) }

desc "Run spec tasks in all remarkable folders"
task :spec do
  remarkable_gems_paths.each do |folder|
    puts
    cd folder
    system "rake spec"
  end
end

desc "Run pre_commit tasks in all remarkable folders"
task :pre_commit do
  remarkable_gems_paths.each do |folder|
    puts
    cd folder
    system "rake pre_commit"
  end
end

task :default => [:pre_commit]
