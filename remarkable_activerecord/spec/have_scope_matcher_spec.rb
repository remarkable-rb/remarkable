require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'have_scope' do
  include ModelBuilder

  before(:each) do
    @model = define_model :product, :title => :string, :category => :string do
      named_scope :recent, :order => 'created_at DESC'
      named_scope :latest, lambda {|c| {:limit => c}}

      def self.beginning(c)
        scoped(:offset => c)
      end

      def self.null
        nil
      end
    end
  end

  describe 'messages' do

    it 'should contain a description' do
      @matcher = have_scope(:title)
      @matcher.description.should == 'have to scope itself to {} when :title is called'

      @matcher.with(1)
      @matcher.description.should == 'have to scope itself to {} when :title is called with 1 as argument'
    end

    it 'should set is_scope? message' do
      @matcher = have_scope(:null)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected :null when called on Product return an instance of ActiveRecord::NamedScope::Scope'
    end

    it 'should set options_match? message' do
      @matcher = have_scope(:recent, :conditions => {:special => true})
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected :recent when called on Product scope to {:conditions=>{:special=>true}}, got {:order=>"created_at DESC"}'
    end

  end

  describe 'matchers' do
    it { should have_scope(:recent) }
    it { should have_scope(:recent, :order => 'created_at DESC') }

    it { should have_scope(:latest,    :with => 10, :limit => 10) }
    it { should have_scope(:beginning, :with => 10, :offset => 10) }

    it { should_not have_scope(:null) }
    it { should_not have_scope(:latest,    :with => 5, :limit => 10) }
    it { should_not have_scope(:beginning, :with => 5, :offset => 10) }
  end

  describe 'macros' do
    should_have_scope :recent
    should_have_scope :recent, :order => 'created_at DESC'

    should_have_scope :latest,    :with => 10, :limit => 10
    should_have_scope :beginning, :with => 10, :offset => 10

    should_not_have_scope :null
    should_not_have_scope :latest,    :with => 5, :limit => 10
    should_not_have_scope :beginning, :with => 5, :offset => 10
  end
end

