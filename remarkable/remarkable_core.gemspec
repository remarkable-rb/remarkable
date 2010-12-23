version = File.read(File.expand_path("../../REMARKABLE_VERSION",__FILE__)).strip
rails_version = File.read(File.expand_path("../../RAILS_VERSION",__FILE__)).strip
rspec_version = File.read(File.expand_path("../../RSPEC_VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.name = %q{remarkable_core}
  s.version = version

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ho-Sheng Hsiao", "Carlos Brando", "Jos\303\251 Valim"]
  s.date = %q{2010-12-23}
  s.description = %q{Remarkable: a framework for rspec matchers and macros, with support for I18n.}
  s.email = ["hosh@sparkfly.com", "eduardobrando@gmail.com", "jose.valim@gmail.com"]
  s.extra_rdoc_files = [
    "CHANGELOG",
     "LICENSE",
     "README"
  ]
  s.files = [
    "CHANGELOG",
     "LICENSE",
     "README",
     "lib/remarkable/core.rb",
     "lib/remarkable/core/base.rb",
     "lib/remarkable/core/core_ext/array.rb",
     "lib/remarkable/core/dsl.rb",
     "lib/remarkable/core/dsl/assertions.rb",
     "lib/remarkable/core/dsl/callbacks.rb",
     "lib/remarkable/core/dsl/optionals.rb",
     "lib/remarkable/core/i18n.rb",
     "lib/remarkable/core/macros.rb",
     "lib/remarkable/core/matchers.rb",
     "lib/remarkable/core/messages.rb",
     "lib/remarkable/core/negative.rb",
     "lib/remarkable/core/rspec.rb",
     "lib/remarkable/core/version.rb",
     "locale/en.yml"
  ]
  s.homepage = %q{http://github.com/carlosbrando/remarkable}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{remarkable}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Remarkable: a framework for rspec matchers and macros, with support for I18n.}

  s.add_dependency('i18n',          '0.4.1')
  s.add_dependency('activesupport', rails_version)
  s.add_dependency('rspec',         rspec_version)
end

