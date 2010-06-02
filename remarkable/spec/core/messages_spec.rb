# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Remarkable::Messages do
  subject { [1, 2, 3] }

  describe 'without I18n' do
    before(:each) do
      @matcher = Remarkable::RSpec::Matchers::ContainMatcher.new(1, 2, 3)
    end

    it 'should provide a description' do
      @matcher.description.should == 'contain the given values'
    end

    it 'should provide a failure message' do
      @matcher.matches?([4])
      @matcher.failure_message.should == 'Expected 1 is included in [4]'
    end

    it 'should provide a negative failure message' do
      @matcher.matches?([1])
      @matcher.negative_failure_message.should == 'Did not expect 2 is included in [1]'
    end

    it 'should provide a not word' do
      @matcher.send(:not_word).should == 'not '
    end
  end

  describe 'with I18n' do
    before(:all) do
      Remarkable.locale = :"pt-BR"
    end

    before(:each) do
      @matcher = Remarkable::RSpec::Matchers::CollectionContainMatcher.new(1, 2, 3)
    end

    it 'should provide a default i18n scope' do
      @matcher.send(:matcher_i18n_scope).should == 'remarkable.r_spec.collection_contain'
    end

    it 'should provide a translated description' do
      @matcher.description.should == 'conter os valores fornecidos'
    end

    it 'should provide a translated failure message' do
      @matcher.matches?([4])
      @matcher.failure_message.should == 'Esperava que 1 estivesse incluso em [4]'
    end

    it 'should provide a translated negative failure message' do
      @matcher.matches?([1])
      @matcher.negative_failure_message.should == 'Não esperava que 2 estivesse incluso em [1]'
    end

    it 'should provide an i18n not word' do
      @matcher.send(:not_word).should == 'não '
    end

    after(:all) do
      Remarkable.locale = :en
    end
  end
end
