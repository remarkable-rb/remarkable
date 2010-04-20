require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'have_readonly_attributes' do
  include ModelBuilder

  def define_and_validate(options={})
    @model = define_model :product, :title => :string, :category => :string do
      attr_readonly :title, :category   if options[:readonly] == true
      attr_readonly *options[:readonly] if options[:readonly].is_a?(Array)
    end

    have_readonly_attributes(:title, :category)
  end

  describe 'messages' do

    it 'should contain a description' do
      @matcher = have_readonly_attributes(:title, :category)
      @matcher.description.should == 'make title and category read-only'
    end

    it 'should set is_readonly? message' do
      @matcher = define_and_validate(:readonly => [:another])
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to make title read-only, got ["another"]'
    end

  end

  describe 'matchers' do
    it { should define_and_validate(:readonly => true) }
    it { should_not define_and_validate(:readonly => false) }
    it { should_not define_and_validate(:accessible => [:another]) }
  end

  describe 'macros' do
    before(:each){ define_and_validate(:readonly => true) }

    should_have_readonly_attributes :title
    should_have_readonly_attributes :category
    should_have_readonly_attributes :title, :category

    should_not_have_readonly_attributes :another
    should_not_have_readonly_attributes :title, :another
  end
end

