require File.dirname(__FILE__) + '/../spec_helper'

describe Remarkable::DSL::Description do
  before(:each) do
    @matcher = Remarkable::Specs::Matchers::SingleContainMatcher.new(1)
  end

  it 'should provide a description with optionals' do
    @matcher.description.should == 'contain 1 not checking for blank'

    @matcher.allow_blank(10)
    @matcher.description.should == 'contain 1 with blank equal 10'

    @matcher.allow_blank(true)
    @matcher.description.should == 'contain 1 with blank equal true'

    @matcher.allow_nil(true)
    @matcher.description.should == 'contain 1 allowing nil and with blank equal true'

    @matcher.allow_nil(false)
    @matcher.description.should == 'contain 1 not allowing nil and with blank equal true'
  end
end
