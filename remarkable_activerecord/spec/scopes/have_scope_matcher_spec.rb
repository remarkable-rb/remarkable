require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'have_scope' do
  include ModelBuilder

  before(:each) do
    @model = define_model :product, :title => :string, :category => :string, :special => :boolean do
      scope :recent, :order => 'created_at DESC'
      scope :latest, lambda {|c| {:limit => c}}
      scope :since, lambda {|t| where(['created_at > ?', t])}
      scope :between, lambda { |a, b| where([ 'created_at > ? and created_at < ?', a, b ]) }

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
      matcher = have_scope(:title)
      matcher.description.should == 'have to scope itself to {} when :title is called'

      matcher.with(1)
      matcher.description.should == 'have to scope itself to {} when :title is called with [1] as argument'
    end

    it 'should set is_scope? message' do
      matcher = have_scope(:null)
      matcher.matches?(@model)
      matcher.failure_message.should == 'Expected :null when called on Product return an instance of ActiveRecord::NamedScope::Scope'
    end

    it 'should set options_match? message' do
      matcher = have_scope(:recent, :where => {:special => true})
      matcher.matches?(@model)
      matcher.failure_message.should match(/^Expected :recent.+/)
    end

  end

  describe 'matchers' do
    it { should have_scope(:recent) }
    it { should have_scope(:recent, :order => 'created_at DESC') }

    it { should have_scope(:latest).with(10).limit(10) }
    it { should have_scope(:beginning).with(10).offset(10) }
    it { should have_scope(:since).with(false).where(["created_at > ?", false]) }
    it { should have_scope(:since).with(Time.at(0)).where(["created_at > ?", Time.at(0)]) }
    it { should have_scope(:between).with(2, 10).where(["created_at > ? and created_at < ?", 2, 10]) }

    it { should_not have_scope(:null) }
    it { should_not have_scope(:latest).with(5).limit(10) }
    it { should_not have_scope(:beginning).with(5).offset(10) }
    it { should_not have_scope(:since).with(Time.at(0)).where(["created_at > ?", Time.at(1)]) }
    it { should_not have_scope(:between).with(2, 10).where(["updated_at > ? and updated_at < ?", 2, 10]) }
  end

  describe 'macros' do
    should_have_scope :recent
    should_have_scope :recent, :order => 'created_at DESC'

    should_have_scope :latest,    :with => 10, :limit => 10
    should_have_scope :beginning, :with => 10, :offset => 10
    should_have_scope :since,     :with => false, :where => ["created_at > ?", false]
    should_have_scope :since,     :with => Time.at(0), :where => ["created_at > ?", Time.at(0)]
    should_have_scope :between,   :with => [ 2, 10 ],  :where => [ "created_at > ? and created_at < ?", 2, 10 ]

    should_have_scope :between do |m|
      m.with(2, 10)
      m.where([ "created_at > ? and created_at < ?", 2, 10 ])
    end

    should_not_have_scope :null
    should_not_have_scope :latest,    :with => 5, :limit => 10
    should_not_have_scope :beginning, :with => 5, :offset => 10
    should_not_have_scope :since,     :with => Time.at(0), :where => ["created_at > ?", Time.at(1)]
    should_not_have_scope :between,   :with => [ 2, 10 ],  :where => [ "updated_at > ? and updated_at < ?", 2, 10 ]
  end
end
