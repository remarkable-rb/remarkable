require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Custom Macros" do
  before(:all) do
    custom_macro = File.join(RAILS_ROOT, "spec", "remarkable_macros", "run_my_custom_macro.rb")
    plugin_macro = File.join(RAILS_ROOT, "vendor", "plugins", "my_plugin", "remarkable_macros", "run_my_plugin_macro.rb")

    [custom_macro, plugin_macro].each do |macro_file|
      File.open(macro_file, "w") do |f|
        f.puts("it 'should run my macro' do\t  true.should be_true\tend")
      end
    end

    load File.expand_path(File.dirname(__FILE__) + '/../../lib/remarkable/rails.rb')
  end

  it { self.class.should respond_to(:should_run_my_custom_macro) }
  it { should run_my_custom_macro }

  it { self.class.should respond_to(:should_run_my_plugin_macro) }
  it { should run_my_plugin_macro }

  after(:all) do
    FileUtils.rm(File.join(RAILS_ROOT, "spec", "remarkable_macros", "run_my_custom_macro.rb"), :force => true)
    FileUtils.rm(File.join(RAILS_ROOT, "vendor", "plugins", "my_plugin", "remarkable_macros", "run_my_plugin_macro.rb"), :force => true)
  end
end
