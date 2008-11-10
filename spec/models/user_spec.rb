require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  fixtures :all
  
  it { User.should have_many(:posts) }
  it { User.should have_many(:dogs) }
  it { User.should have_many(:friendships) }
  it { User.should have_many(:friends) }
  it { User.should have_many(:posts, :dogs, :friendships, :friends) }
  
  it { User.should have_one(:address) }
  it { User.should have_one(:address, :dependent => :destroy) }
  
  it { User.should have_indices(:email, :name, [:email, :name]) }
  it { User.should have_index(:age) }
  
  it { User.should have_named_scope(:old, :conditions => "age > 50") }
  it { User.should have_named_scope(:eighteen, :conditions => { :age => 18 }) }

  it { User.should have_named_scope('recent(5)', :limit => 5) }
  it { User.should have_named_scope('recent(1)', :limit => 1) }
  it { User.should have_named_scope('recent_via_method(7)', :limit => 7) }

  describe "when given an instance variable" do
    before do
      @count = 2
    end
    it { User.should have_named_scope("recent(#{@count})", :limit => 2) }
  end
  
  it { User.should_not allow_values_for(:email, "blah", "b lah") }
  it { User.should allow_values_for(:email, "a@b.com", "asdf@asdf.com") }
  it { User.should ensure_length_in_range(:email, 1..100) }
  it { User.should ensure_value_in_range(:age, 1..100) }
  it { User.should protect_attributes(:password) }
  it { User.should have_class_methods(:find, :destroy) }
  it { User.should have_instance_methods(:email, :age, :email=, :valid?) }
  
  it { User.should have_db_columns(:name, :email, :age) }
  it { User.should have_db_column(:name) }
  it { User.should have_db_column(:id, :type => "integer", :primary => true) }
  it { User.should have_db_column(:email, :type => "string",  :default => nil,    :precision => nil,  :limit => 255,
                                          :null => true,      :primary => false,  :scale => nil,      :sql_type => 'varchar(255)') }
  
  it { User.should require_acceptance_of(:eula) }
  it { User.should require_unique_attributes(:email, :scoped_to => :name) }
  
  it { User.should ensure_length_is(:ssn, 9, :message => "Social Security Number is not the right length") }
  it { User.should only_allow_numeric_values_for(:ssn) }
  
  it { User.should have_readonly_attributes(:name) }
  
  it { Tag.should_not protect_attributes(:name, :age) }
end
