require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'have_column_matcher' do
  include ModelBuilder

  before(:each) do
    @model = define_model :product, :table => lambda {|table|
      table.string  :name,  :null => true
      table.string  :email, :limit => '255', :default => 'jose.valim@gmail.com'
      table.decimal :price, :precision => 10, :scale => 2
    }
  end

  describe 'messages' do

    it 'should contain a description' do
      @matcher = have_column(:name, :email)
      @matcher.description.should == 'have column(s) named name and email'

      @matcher.type(:string)
      @matcher.description.should == 'have column(s) named name and email with type :string'
    end

    it 'should set column_exists? message' do
      @matcher = have_column(:password)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to have column named password'
    end

    it 'should set options_match? message' do
      @matcher = have_column(:name, :type => :integer)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to have column name with options {:type=>"integer"}, got {:type=>"string"}'
    end
  end

  describe 'matchers' do
    it { should have_column(:name) }
    it { should have_columns(:name, :email) }
    it { should have_columns(:name, :email, :price) }

    it { should have_column(:name).null }
    it { should have_column(:email).limit(255) }
    it { should have_column(:email).default('jose.valim@gmail.com') }
    it { should have_column(:price).precision(10) }
    it { should have_column(:price).precision(10).scale(2) }

    it { should_not have_column(:name).null(false) }
    it { should_not have_column(:email).limit(400) }
    it { should_not have_column(:email).default('') }
    it { should_not have_column(:price).precision(1) }
    it { should_not have_column(:price).precision(10).scale(5) }
  end

  describe 'macros' do
    should_have_column :name
    should_have_columns :name, :email
    should_have_columns :name, :email, :price

    should_have_column :name,  :null => true
    should_have_column :email, :limit => 255
    should_have_column :email, :default => 'jose.valim@gmail.com'
    should_have_column :price, :precision => 10
    should_have_column :price, :precision => 10, :scale => 2

    should_not_have_column :name,  :null => false
    should_not_have_column :email, :limit => 400
    should_not_have_column :email, :default => ''
    should_not_have_column :price, :precision => 1
    should_not_have_column :price, :precision => 10, :scale => 5
  end
end

