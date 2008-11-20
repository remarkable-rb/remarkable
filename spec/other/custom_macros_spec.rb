require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Custom Plugin Macros" do
  it { self.class.should respond_to(:should_run_my_custom_macro) }
  it { should run_my_custom_macro }
  should_run_my_custom_macro

  it { self.class.should respond_to(:should_run_my_plugin_macro) }
  it { should run_my_plugin_macro }
  should_run_my_plugin_macro  
end
