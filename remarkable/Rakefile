require 'rubygems'

gem 'rspec', ENV['RSPEC_VERSION'] || '1.2.2'
require 'spec/rake/spectask'

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Run the specs under spec"
task :pre_commit do
  puts "\n=> remarkable: rake spec"
  Rake::Task[:spec].execute
end
