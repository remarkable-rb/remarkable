%w[rubygems rake rake/clean fileutils newgem rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/remarkable'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('remarkable', Remarkable::VERSION) do |p|
  p.developer 'Carlos Brando',  'eduardobrando@gmail.com'
  p.developer 'José Valim',     'jose.valim@gmail.com'
  p.developer 'Diego Carrion',  'dc.rec1@gmail.com'
  
  p.url = 'http://www.nomedojogo.com/2008/11/18/shoulda-for-rspec-is-remarkable/'
  p.summary = 'Remarkable is a framework for Rspec matchers.'
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  p.rubyforge_name       = p.name # TODO this is default value
  
  p.extra_deps         = [
    ['rspec','>= 1.1.12'],
    ['rspec-rails','>= 1.1.12']
  ]
  
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]

  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
task :default => [:spec, :features]
require 'spec/rake/spectask'
desc "Run the specs under spec/models"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end
