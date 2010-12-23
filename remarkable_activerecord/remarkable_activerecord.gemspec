version = File.read(File.expand_path("../../REMARKABLE_VERSION",__FILE__)).strip
rails_version = File.read(File.expand_path("../../RAILS_VERSION",__FILE__)).strip
rspec_version = File.read(File.expand_path("../../RSPEC_VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.name = %q{remarkable_activerecord}
  s.version = version

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ho-Sheng Hsiao", "Carlos Brando", "Jos\303\251 Valim", "Diego Carrion"]
  s.date = %q{2010-12-23}
  s.description = %q{Remarkable ActiveRecord: collection of matchers and macros with I18n for ActiveRecord}
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
     "lib/remarkable/active_record.rb",
     "lib/remarkable/active_record/base.rb",
     "lib/remarkable/active_record/matchers/accept_nested_attributes_for_matcher.rb",
     "lib/remarkable/active_record/matchers/allow_mass_assignment_of_matcher.rb",
     "lib/remarkable/active_record/matchers/association_matcher.rb",
     "lib/remarkable/active_record/matchers/have_column_matcher.rb",
     "lib/remarkable/active_record/matchers/have_default_scope_matcher.rb",
     "lib/remarkable/active_record/matchers/have_index_matcher.rb",
     "lib/remarkable/active_record/matchers/have_readonly_attributes_matcher.rb",
     "lib/remarkable/active_record/matchers/have_scope_matcher.rb",
     "lib/remarkable/active_record/matchers/validate_associated_matcher.rb",
     "lib/remarkable/active_record/matchers/validate_uniqueness_of_matcher.rb",
     "locale/en.yml"
  ]
  s.homepage = %q{http://github.com/carlosbrando/remarkable}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{remarkable}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Remarkable ActiveRecord: collection of matchers and macros with I18n for ActiveRecord}

  s.add_dependency('rspec',      rspec_version)
  s.add_dependency('remarkable_core', version)
  s.add_dependency('remarkable_activemodel', version)
  s.add_dependency('activerecord', rails_version)
end

