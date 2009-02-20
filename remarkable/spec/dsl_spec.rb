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

    describe "and I18n" do
      before(:each) do
        @matcher = Remarkable::Specs::Matchers::CollectionContainMatcher.new(1, 2, 3)
      end

      it 'should provide a description' do
        @matcher.description.should == 'contain 1, 2, and 3'
      end

      it 'should provide a expectation' do
        @matcher.matches?([4])
        @matcher.expectation.should == '1 is included in [4]'
      end

      it 'should provide a failure message' do
        @matcher.matches?([4])
        @matcher.failure_message.should == 'Expected 1 is included in [4] (1 is not included in [4])'
      end

      it 'should provide a negative failure message' do
        @matcher.negative.matches?([1])
        @matcher.negative_failure_message.should == 'Did not expect 1 is included in [1]'
      end
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

  describe "with optionals" do
    before(:each) do
      @matcher = Remarkable::Specs::Matchers::BeAPersonMatcher.new
    end

    it "should store given value properly" do
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

    describe "and I18n" do
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
  end

end
