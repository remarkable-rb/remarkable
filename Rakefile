require "rubygems"
require "fileutils"

include FileUtils

desc "Run the pre_commit tasks in all remarkable folders"
task :pre_commit do
  dir     = File.dirname(__FILE__)
  folders = [ File.join(dir, 'remarkable') ] + Dir[ File.join(dir, 'remarkable_*') ]

  folders.each do |folder|
    puts
    cd folder
    system "rake pre_commit"
  end
end

task :default => [:pre_commit]
