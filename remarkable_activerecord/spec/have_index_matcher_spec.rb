require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'have_index_matcher' do
  include ModelBuilder

  before(:each) do
    @model = define_model :users, :table => lambda {|table|
      table.string  :name,  :null => true
      table.string  :email, :limit => '255', :default => 'jose.valim@gmail.com'
    }

    ActiveRecord::Base.connection.add_index :users, :name
    ActiveRecord::Base.connection.add_index :users, :email, :unique => true
    ActiveRecord::Base.connection.add_index :users, [:email, :name], :unique => true
  end

  describe 'messages' do

    it 'should contain a description' do
      @matcher = have_index(:name)
      @matcher.description.should == 'have index for column(s) name'

      @matcher.unique
      @matcher.description.should == 'have index for column(s) name with unique values'
    end

    it 'should set index_exists? message' do
      @matcher = have_index(:password)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected index password to exist on table users'
    end

    it 'should set is_unique? message' do
      @matcher = have_index(:email, :unique => false)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected index on email with unique equals to false, got true'
    end
  end

  describe 'matchers' do
    it { should have_index(:name) }
    it { should have_index(:email) }
    it { should have_index([:email, :name]) }
    it { should have_indices(:name, :email) }

    it { should have_index(:name).unique(false) }
    it { should have_index(:email).unique }

    it { should_not have_index(:password) }
    it { should_not have_index(:name).unique(true) }
    it { should_not have_index(:email).unique(false) }
  end

  describe 'macros' do
    should_have_index :name
    should_have_index :email
    should_have_index [:email, :name]
    should_have_indices :name, :email

    should_have_index :name, :unique => false
    should_have_index :email, :unique => true

    should_not_have_index :password
    should_not_have_index :name, :unique => true
    should_not_have_index :email, :unique => false
  end
end

