require File.dirname(__FILE__) + '/spec_helper'

describe Remarkable::DSL do

  describe "with collection" do
    subject { [1, 2, 3] }

    it 'should provide default structure for assertions' do
      should collection_contain(1)
      should collection_contain(1, 2)
      should collection_contain(1, 2, 3)

      should_not collection_contain(4)
      should_not collection_contain(1, 4)
    end

    it 'should provide default structure for single assertions' do
      nil.should_not collection_contain(1)
    end

    it 'should hold default options' do
      matcher = Remarkable::Specs::Matchers::CollectionContainMatcher.new(1, 2, 3)
      matcher.instance_variable_get('@options').should == { :working => true }
    end
  end

  describe "without collection" do
    subject { [1, 2, 3] }

    it 'should provide default structure for assertions' do
      should single_contain(1)
      should_not single_contain(4)
    end

    it 'should provide default structure for single assertions' do
      nil.should_not single_contain(1)
    end

    it 'should hold default options' do
      matcher = Remarkable::Specs::Matchers::CollectionContainMatcher.new(1, 2, 3)
      matcher.instance_variable_get('@options').should == { :working => true }
    end
  end

end
