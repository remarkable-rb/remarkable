require "rake/clean"
require "rake/gempackagetask"
require 'fileutils'
include FileUtils

remarkable_more_gem_paths = %w[]
remarkable_gem_paths = %w[remarkable] + remarkable_more_gem_paths
# remarkable-core remarkable-activerecord

desc "Run spec examples for Remarkable More gems, one by one."
task :spec do
  remarkable_gem_paths.each do |gem|
    Dir.chdir(gem) { sh "#{Gem.ruby} -S rake spec" }
  end
end

desc 'Default: run spec examples for all the gems.'
task :default => 'spec'
