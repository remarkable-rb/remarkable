require File.dirname(__FILE__) + '/spec_helper'

describe Remarkable::Messages do
  subject { [1, 2, 3] }

  before(:each) do
    @matcher = Remarkable::Specs::Matchers::ContainMatcher.new(1, 2, 3)
  end

  describe 'without I18n' do
    it 'should provide a description' do
      @matcher.description.should == 'contain the given values'
    end

    it 'should provide a expectation' do
      @matcher.matches?([4])
      @matcher.expectation.should == 'the given values are included in [4] which is a Array'
    end

    it 'should provide a failure message' do
      @matcher.matches?([4])
      @matcher.failure_message.should == 'Expected the given values are included in [4] which is a Array (1 is not included in [4])'
    end

    it 'should provide a negative failure message' do
      @matcher.negative.matches?([1])
      @matcher.negative_failure_message.should == 'Did not expect the given values are included in [1] which is a Array'
    end

    it 'should provide a not word' do
      @matcher.send(:not_word).should == 'not'
    end
  end

  describe 'with I18n' do
    before(:all) do
      Remarkable.locale = :"pt-BR"
    end

    it 'should provide a default i18n scope' do
      @matcher.send(:matcher_i18n_scope).should == 'remarkable.specs.contain'
    end

    it 'should provide a translated description' do
      @matcher.description.should == 'conter os valores fornecidos'
    end

    it 'should provide a translated expectation' do
      @matcher.matches?([4])
      @matcher.expectation.should == 'os valores fornecidos sejam inclusos em [4]'
    end

    it 'should provide a translated failure message' do
      @matcher.matches?([4])
      @matcher.failure_message.should == 'Esperava que os valores fornecidos sejam inclusos em [4] (1 is not included in [4])'
    end

    it 'should provide a translated negative failure message' do
      @matcher.negative.matches?([1])
      @matcher.negative_failure_message.should == 'Não esperava que os valores fornecidos sejam inclusos em [1]'
    end

    it 'should provide an i18n not word' do
      @matcher.send(:not_word).should == 'não'
    end

    after(:all) do
      Remarkable.locale = :en
    end
  end
end
