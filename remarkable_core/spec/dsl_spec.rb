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

    it 'should provide default options' do
      matcher = Remarkable::Specs::Matchers::CollectionContainMatcher.new(1, 2, 3, :args => true)
      matcher.instance_variable_get('@options').should == { :working => true, :args => true }
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

    it 'should provide default options' do
      matcher = Remarkable::Specs::Matchers::SingleContainMatcher.new(1, :args => true)
      matcher.instance_variable_get('@options').should == { :working => true, :args => true }
    end
  end

  describe "with blocks" do
    subject { [1, 2, 3] }

    it 'should accept blocks as argument' do
      should_not single_contain(4)
      should single_contain(4){ |array| array << 4 }
    end

    it 'should provide an interface for after initialize hook' do
      matcher = Remarkable::Specs::Matchers::CollectionContainMatcher.new(1)
      matcher.instance_variable_get('@after_initialize').should be_true
    end

    it 'should provide an interface for before assert hook' do
      matcher = Remarkable::Specs::Matchers::CollectionContainMatcher.new(1)
      [1, 2, 3].should matcher
      matcher.instance_variable_get('@before_assert').should be_true
    end
  end

  describe "instance methods" do
    it 'should provide an after initialize hook' do
      matcher = Remarkable::Specs::Matchers::SingleContainMatcher.new(1)
      matcher.instance_variable_get('@after_initialize').should be_true
    end

    it 'should provide a before assert hook' do
      matcher = Remarkable::Specs::Matchers::SingleContainMatcher.new(1)
      [1, 2, 3].should matcher
      matcher.instance_variable_get('@before_assert').should be_true
    end
  end

  describe "with options" do
    xit "should store given value properly"
    xit "should allow defaults values"
    xit "should allow alias to be set"
  end
end
