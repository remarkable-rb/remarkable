# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{remarkable}
  s.version = "2.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Carlos Brando", "Jos\303\251 Valim", "Diego Carrion"]
  s.date = %q{2009-02-12}
  s.description = %q{}
  s.email = ["eduardobrando@gmail.com", "jose.valim@gmail.com", "dc.rec1@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "init.rb", "lib/remarkable.rb", "lib/remarkable/active_record/README.markdown", "lib/remarkable/active_record/active_record.rb", "lib/remarkable/active_record/helpers.rb", "lib/remarkable/active_record/macros.rb", "lib/remarkable/active_record/macros/associations/association_matcher.rb", "lib/remarkable/active_record/macros/callbacks/callback_matcher.rb", "lib/remarkable/active_record/macros/database/have_db_column_matcher.rb", "lib/remarkable/active_record/macros/database/index_matcher.rb", "lib/remarkable/active_record/macros/validations/allow_mass_assignment_of_matcher.rb", "lib/remarkable/active_record/macros/validations/ensure_value_in_list_matcher.rb", "lib/remarkable/active_record/macros/validations/ensure_value_in_range_matcher.rb", "lib/remarkable/active_record/macros/validations/have_class_methods_matcher.rb", "lib/remarkable/active_record/macros/validations/have_instance_methods_matcher.rb", "lib/remarkable/active_record/macros/validations/have_named_scope_matcher.rb", "lib/remarkable/active_record/macros/validations/have_readonly_attributes_matcher.rb", "lib/remarkable/active_record/macros/validations/protect_attributes_matcher.rb", "lib/remarkable/active_record/macros/validations/validate_acceptance_of_matcher.rb", "lib/remarkable/active_record/macros/validations/validate_associated_matcher.rb", "lib/remarkable/active_record/macros/validations/validate_confirmation_of_matcher.rb", "lib/remarkable/active_record/macros/validations/validate_exclusion_of_matcher.rb", "lib/remarkable/active_record/macros/validations/validate_format_of_matcher.rb", "lib/remarkable/active_record/macros/validations/validate_inclusion_of_matcher.rb", "lib/remarkable/active_record/macros/validations/validate_length_of_matcher.rb", "lib/remarkable/active_record/macros/validations/validate_numericality_of_matcher.rb", "lib/remarkable/active_record/macros/validations/validate_presence_of_matcher.rb", "lib/remarkable/active_record/macros/validations/validate_uniqueness_of_matcher.rb", "lib/remarkable/assertions.rb", "lib/remarkable/controller/README.markdown", "lib/remarkable/controller/controller.rb", "lib/remarkable/controller/helpers.rb", "lib/remarkable/controller/macros.rb", "lib/remarkable/controller/macros/assign_matcher.rb", "lib/remarkable/controller/macros/filter_params_matcher.rb", "lib/remarkable/controller/macros/metadata_matcher.rb", "lib/remarkable/controller/macros/render_with_layout_matcher.rb", "lib/remarkable/controller/macros/respond_with_content_type_matcher.rb", "lib/remarkable/controller/macros/respond_with_matcher.rb", "lib/remarkable/controller/macros/set_session_matcher.rb", "lib/remarkable/controller/macros/route_matcher.rb", "lib/remarkable/controller/macros/set_the_flash_to_matcher.rb", "lib/remarkable/dsl.rb", "lib/remarkable/example/example_methods.rb", "lib/remarkable/helpers.rb", "lib/remarkable/matcher_base.rb", "lib/remarkable/private_helpers.rb", "lib/remarkable/rails.rb", "lib/remarkable/rails/extract_options.rb", "rails/init.rb", "remarkable.gemspec", "script/console", "script/destroy", "script/generate", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.homepage = %q{http://www.nomedojogo.com/2008/11/18/shoulda-for-rspec-is-remarkable/}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{remarkable}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Remarkable is a framework for Rspec matchers.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, [">= 1.1.12"])
      s.add_runtime_dependency(%q<rspec-rails>, [">= 1.1.12"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.1.12"])
      s.add_dependency(%q<rspec-rails>, [">= 1.1.12"])
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.1.12"])
    s.add_dependency(%q<rspec-rails>, [">= 1.1.12"])
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
