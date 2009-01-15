require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  fixtures :all
  
  it { should have_many(:posts) }
  it { should have_many(:dogs) }
  it { should have_many(:friendships) }
  it { should have_many(:friends) }
  it { should have_many(:posts, :dogs, :friendships, :friends) }
  
  it { should have_one(:address) }
  it { should have_one(:address).dependent(:destroy) }
  it { should have_one(:address, :dependent => :destroy) }
  
  it { should_not have_index(:foo, :bar) }
  it { should have_indices(:email, :name, [:email, :name]) }
  it { should have_index(:age) }
  it { should_not have_index(:aged) }
  
  it { should have_named_scope(:old)}
  it { should have_named_scope(:old, :conditions => "age > 50") }
  it { should_not have_named_scope(:old, :conditions => "age > 49") }
  it { should have_named_scope(:eighteen, :conditions => { :age => 18 }) }
  it { should_not have_named_scope(:eighteen, :conditions => { :age => 17 }) }
  
  it { should have_named_scope('recent(5)') }
  it { should have_named_scope('recent(5)', :limit => 5) }
  it { should_not have_named_scope('recent(5)', :limit => 4) }
  it { should have_named_scope('recent(1)', :limit => 1) }
  it { should_not have_named_scope('recent(1)', :limit => 2) }
  it { should have_named_scope('recent_via_method(7)', :limit => 7) }
  it { should_not have_named_scope('recent_via_method(7)', :limit => 8) }
  
  describe "when given an instance variable" do
    before(:each) do
      @count = 2
    end
    it { should have_named_scope("recent(#{@count})", :limit => 2) }
    it { should_not have_named_scope("recent(#{@count})", :limit => 1) }
  end
  
  it { should have_after_create_callback(:send_welcome_email) }
  it { should_not have_after_save_callback(:send_welcome_email) }
  it { should_not have_after_destroy_callback(:goodbye_jerk) }
  it { should have_before_validation_on_update_callback(:some_weird_callback) }
  
  it { should_not allow_values_for(:email, "blah", "b lah") }
  it { should allow_values_for(:email, "a@b.com", "asdf@asdf.com") }
  it { should_not allow_values_for(:email, "a@b.com", "asdf@asdf.com").allow_nil }
  it { should_not allow_values_for(:email, "a@b.com", "asdf@asdf.com").allow_nil(true) }
  it { should allow_values_for(:email, "a@b.com", "asdf@asdf.com").allow_nil(false) }
  
  it { should ensure_length_in_range(:email, 2..100) }
  it { should_not ensure_length_in_range(:email, 1..100) }
  it { should_not ensure_length_in_range(:email, 2..101) }
  it { should_not ensure_length_in_range(:email, 3..100) }
  it { should_not ensure_length_in_range(:email, 2..99) }
  
  it { should ensure_value_in_range(:age, 2..100) }
  it { should_not ensure_value_in_range(:age, 1..100) }
  it { should_not ensure_value_in_range(:age, 2..101) }
  it { should_not ensure_value_in_range(:age, 3..100) }
  it { should_not ensure_value_in_range(:age, 2..99) }
  
  it { should protect_attributes(:password) }
  it { should_not protect_attributes(:name, :age) }
  
  it { should have_class_methods(:find) }
  it { should_not have_class_methods(:foo) }
  it { should have_class_methods(:find, :destroy) }
  it { should_not have_class_methods(:foo, :bar) }
  
  it { should have_instance_methods(:email) }
  it { should_not have_instance_methods(:foo) }
  it { should have_instance_methods(:email, :age, :email=, :valid?) }
  it { should_not have_instance_methods(:foo, :bar) }
  
  it { should_not have_db_column(:foo) }
  it { should_not have_db_columns(:foo, :bar) }
  it { should have_db_columns(:name, :email, :age) }
  it { should have_db_columns(:name, :email, :type => "string") }
  it { should_not have_db_columns(:name, :email, :type => "integer") }
  it { should have_db_columns(:name, :email).type("string") }
  it { should_not have_db_columns(:foo, :bar).type("string") }
  
  it { should have_db_column(:name) }
  it { should have_db_column(:id).type("integer").primary(true) }
  it { should have_db_column(:id).type("integer").primary }
  it { should have_db_column(:email).type("string").default(nil).precision(nil).limit(255).null(true).primary(false).scale(nil).sql_type('varchar(255)') }
  it { should have_db_column(:email).type("string") }
  it { should_not have_db_column(:email).type("integer") }
  it { should have_db_column(:email).default(nil) }
  it { should_not have_db_column(:email).default('foo') }
  it { should have_db_column(:email).precision(nil) }
  it { should_not have_db_column(:email).precision(10) }
  it { should have_db_column(:email).limit(255) }
  it { should_not have_db_column(:email).limit(254) }
  it { should have_db_column(:email).null(true) }
  it { should have_db_column(:email).null }
  it { should_not have_db_column(:email).null(false) }
  it { should have_db_column(:email).primary(false) }
  it { should_not have_db_column(:email).primary }
  it { should_not have_db_column(:email).primary(true) }
  it { should have_db_column(:email).scale(nil) }
  it { should_not have_db_column(:email).scale(2) }
  it { should have_db_column(:email).sql_type('varchar(255)') }
  it { should_not have_db_column(:email).sql_type('varchar(254)') }
  it { should have_db_column(:email, :type => "string").limit(255) }
  it { should_not have_db_column(:email, :type => "integer").limit(255) }
  it { should have_db_column(:email,  :type => "string",  :default => nil,    :precision => nil,  :limit => 255,
                                      :null => true,      :primary => false,  :scale => nil,      :sql_type => 'varchar(255)') }

  it { should require_acceptance_of(:eula) }
  it { should_not require_acceptance_of(:name) }
  
  it { should require_unique_attributes(:email, :scoped_to => :name) }
  
  it { should ensure_length_is(:ssn, 9, :message => "Social Security Number is not the right length") }
  it { should ensure_length_is(:ssn, 9).message("Social Security Number is not the right length") }
  it { should_not ensure_length_is(:ssn, 9) }
  it { should_not ensure_length_is(:ssn, 8).message("Social Security Number is not the right length") }
  it { should_not ensure_length_is(:ssn, 10).message("Social Security Number is not the right length") }
  
  it { should only_allow_numeric_values_for(:ssn) }
  
  it { should have_readonly_attributes(:name) }
  it { should_not have_readonly_attributes(:foo) }
  it { should_not have_readonly_attributes(:ssn) }
end

describe User do
  fixtures :all
  
  should_have_many :posts
  should_have_many :dogs
  should_have_many :friendships
  should_have_many :friends
  should_have_many :posts, :dogs, :friendships, :friends
  
  should_have_one :address
  should_have_one :address, :dependent => :destroy
  
  should_have_indices :email, :name, [:email, :name]
  should_have_index :age
  
  should_have_named_scope :old, :conditions => "age > 50"
  should_have_named_scope :eighteen, :conditions => { :age => 18 }
  
  should_have_named_scope 'recent(5)', :limit => 5
  should_have_named_scope 'recent(1)', :limit => 1
  should_have_named_scope 'recent_via_method(7)', :limit => 7
  
  describe "when given an instance variable" do
    before(:each) do
      @count = 2
    end
    # should_have_named_scope "recent(@count)", :limit => 2
  end

  should_have_after_create_callback(:send_welcome_email)
  should_not_have_after_save_callback(:send_welcome_email)
  should_not_have_after_destroy_callback(:goodbye_jerk)
  should_have_before_validation_on_update_callback(:some_weird_callback)
  
  should_not_allow_values_for :email, "blah", "b lah"
  should_allow_values_for :email, "a@b.com", "asdf@asdf.com"
  should_ensure_length_in_range :email, 2..100
  should_ensure_value_in_range :age, 2..100
  should_protect_attributes :password
  should_have_class_methods :find, :destroy
  should_have_instance_methods :email, :age, :email=, :valid?
  
  should_have_db_columns :name, :email, :age
  should_have_db_columns :name, :email, :type => "string"
  
  should_have_db_column :name
  should_have_db_column :id, :type => "integer", :primary => true
  should_have_db_column :email, :type => "string",  :default => nil,    :precision => nil,  :limit => 255,
                                :null => true,      :primary => false,  :scale => nil,      :sql_type => 'varchar(255)'
  
  should_require_acceptance_of :eula
  should_require_unique_attributes :email, :scoped_to => :name
  
  should_ensure_length_is :ssn, 9, :message => "Social Security Number is not the right length"
  should_only_allow_numeric_values_for :ssn
  
  should_have_readonly_attributes :name
end
