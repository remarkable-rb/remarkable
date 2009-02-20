require File.dirname(__FILE__) + '/../spec_helper'

describe Remarkable::DSL::Optionals do
  before(:each) do
    @matcher = Remarkable::Specs::Matchers::BeAPersonMatcher.new
  end

  it "should create optional methods on the fly" do
    @matcher.first_name('José')
    @matcher.instance_variable_get('@options')[:first_name].should == 'José'

    @matcher.last_name('Valim')
    @matcher.instance_variable_get('@options')[:last_name].should == 'Valim'
  end

  it "should allow defaults values" do
    @matcher.age
    @matcher.instance_variable_get('@options')[:age].should == 18
  end

  it "should allow alias to be set" do
    @matcher.family_name('Valim')
    @matcher.instance_variable_get('@options')[:last_name].should == 'Valim'
  end
end
