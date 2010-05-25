require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Remarkable::I18n do
  subject { [1, 2, 3] }

  before(:all) do
    Remarkable.locale = :"pt-BR"
  end

  it 'should have a locale apart from I18n' do
    I18n.locale.should_not == Remarkable.locale
  end

  it 'should delegate translate to I18n API overwriting the default locale' do
    ::I18n.should_receive(:translate).with('remarkable.core.not', :locale => :"pt-BR").and_return('translated')
    Remarkable.t('remarkable.core.not').should == 'translated'
  end

  it 'should delegate localize to I18n API overwriting the default locale' do
    ::I18n.should_receive(:localize).with('remarkable.core.not', :locale => :"pt-BR").and_return('localized')
    Remarkable.l('remarkable.core.not').should == 'localized'
  end

  it 'should delegate add_locale to I18n backend' do
    backend = mock(::I18n::Backend)
    ::I18n.should_receive(:backend).and_return(backend)
    backend.should_receive(:load_translations).with('a', 'b', 'c')

    Remarkable.add_locale('a', 'b', 'c')
  end

  after(:all) do
    Remarkable.locale = :en
  end

  Remarkable.locale = :"pt-BR"
  should_collection_contain(1)
  should_not_collection_contain(4)
  xshould_not_collection_contain(5)
  Remarkable.locale = :en
end
