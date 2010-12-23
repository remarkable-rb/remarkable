version = File.read(File.expand_path("../../REMARKABLE_VERSION",__FILE__)).strip
rails_version = File.read(File.expand_path("../../RAILS_VERSION",__FILE__)).strip
rspec_version = File.read(File.expand_path("../../RSPEC_VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.name = %q{remarkable_activemodel}
  s.version = version

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ho-Sheng Hsiao", "Carlos Brando", "Jos\303\251 Valim", "Diego Carrion"]
  s.date = %q{2010-12-23}
  s.description = %q{Remarkable ActiveModel: collection of matchers and macros with I18n for ActiveModel}
  s.email = ["hosh@sparkfly.com", "eduardobrando@gmail.com", "jose.valim@gmail.com", "dc.rec1@gmail.com"]
  s.extra_rdoc_files = [
    "CHANGELOG",
     "LICENSE",
     "README"
  ]
  s.files = [
    "CHANGELOG",
     "LICENSE",
     "README",
     "lib/remarkable/active_model.rb",
     "lib/remarkable/active_model/base.rb",
     "lib/remarkable/active_model/matchers/allow_values_for_matcher.rb",
     "lib/remarkable/active_model/matchers/validate_acceptance_of_matcher.rb",
     "lib/remarkable/active_model/matchers/validate_confirmation_of_matcher.rb",
     "lib/remarkable/active_model/matchers/validate_exclusion_of_matcher.rb",
     "lib/remarkable/active_model/matchers/validate_inclusion_of_matcher.rb",
     "lib/remarkable/active_model/matchers/validate_length_of_matcher.rb",
     "lib/remarkable/active_model/matchers/validate_numericality_of_matcher.rb",
     "lib/remarkable/active_model/matchers/validate_presence_of_matcher.rb",
     "locale/en.yml"
  ]
  s.homepage = %q{http://github.com/carlosbrando/remarkable}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{remarkable}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Remarkable ActiveModel: collection of matchers and macros with I18n for ActiveModel}

  s.add_dependency('rspec',      rspec_version)
  s.add_dependency('remarkable_core', version)
end

