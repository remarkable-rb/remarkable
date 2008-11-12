require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the remarkable plugin.'
Spec::Rake::SpecTask.new(:test) do |t|
  t.spec_opts = ['--options', "\"./spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Generate documentation for the remarkable plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Remarkable'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
