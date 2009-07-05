require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'loader' do
  it "should load files in the plugin folder" do
    defined?(MyPlugin::Matchers).should == "constant"
  end

  it "should load files in the plugin folder" do
    I18n.t("my_plugin_locale").should == "My plugin locale"
  end
end
