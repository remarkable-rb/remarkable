require 'rubygems'
require 'spec/rake/spectask'

RAILS_VERSIONS = ['2.1.2', '2.2.2', '2.3.2']

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Run the specs under spec with supported Rails versions"
task :pre_commit do
  RAILS_VERSIONS.each do |version|
    ENV['RAILS_VERSION'] = version
    puts "\n=> remarkable_activerecord: rake spec RAILS_VERSION=#{version}"
    Rake::Task[:spec].execute
  end
end
