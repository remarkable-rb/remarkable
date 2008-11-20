if defined?(RAILS_ROOT)

  module Remarkable
    module Syntax
      module Shoulda
        module CustomMacro; end
      end
      module RSpec
        module CustomMacro; end
      end
    end
  end

  def create_macro_methods(macro)
    method_name = File.basename(macro, ".rb")
    Remarkable::Syntax::Shoulda::CustomMacro::send(:define_method, "should_#{method_name}") { instance_eval(IO.read(macro)) }
    Remarkable::Syntax::RSpec::CustomMacro::send(:define_method, method_name) do 
      return simple_matcher(method_name.humanize.downcase) do
        self.class.describe do
          describe "(#{method_name})" do
            instance_eval(IO.read(macro)) 
          end
        end
      end
    end
  end

  # load in the 3rd party macros from vendorized plugins and gems
  Dir[File.join(RAILS_ROOT, "vendor", "{plugins, gems}", "*", "remarkable_macros", "*.rb")].each do |macro|
    create_macro_methods(macro)
  end

  # load in the local application specific macros
  Dir[File.join(RAILS_ROOT, "spec", "remarkable_macros", "*.rb")].each do |macro|
    create_macro_methods(macro)
  end

  Spec::Rails::Matchers.send(:include, Remarkable::Syntax::RSpec::CustomMacro) if defined?(Remarkable::Syntax::RSpec::CustomMacro)
  Spec::Example::ExampleGroupMethods.send(:include, Remarkable::Syntax::Shoulda::CustomMacro) if defined?(Remarkable::Syntax::Shoulda::CustomMacro)
end
