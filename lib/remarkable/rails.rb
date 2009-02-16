if defined?(RAILS_ROOT)

  require "remarkable/rails/extract_options"

  def create_macro_methods(macro)
    method_name = File.basename(macro, ".rb")
    Spec::Example::ExampleGroupMethods::send(:define_method, "should_#{method_name}") { instance_eval(IO.read(macro)) }

    Spec::Rails::Matchers::send(:define_method, method_name) do 
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
end
