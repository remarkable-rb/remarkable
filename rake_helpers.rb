# encoding: utf-8
require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require "rake"
require "rspec/core/rake_task"

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
  t.verbose = false
end
