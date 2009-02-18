require File.dirname(__FILE__) + '/spec_helper'

describe Remarkable::Base do
  subject { [1, 2, 3] }

  before(:all) do
    Remarkable.locale = :"pt-BR"
  end

  before(:each) do
    @matcher = Remarkable::Specs::Matchers::ContainMatcher.new(1, 2, 3)
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

  it 'should have a locale apart from I18n' do
    I18n.locale.should_not == Remarkable.locale
  end

  after(:all) do
    Remarkable.locale = :en
  end

  Remarkable.locale = :"pt-BR"
  should_contain(1)
  should_not_contain(4)
  xshould_not_contain(5)
  Remarkable.locale = :en
end
