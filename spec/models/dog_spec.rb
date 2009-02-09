require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Pets::Dog do
  it { should belong_to(:user) }
  it { should belong_to(:address) }
  it { should belong_to(:user, :address) }
  it { should_not belong_to(:foo, :bar) }
  
  it { should have_and_belong_to_many(:fleas) }
  
  it { should only_allow_numeric_values_for(:age).allow_blank }
  it { should only_allow_numeric_values_for(:age).allow_blank(true) }
  it { should only_allow_numeric_values_for(:age, :allow_blank => true) }
  
  it { should_not only_allow_numeric_values_for(:age).allow_blank(false) }
  it { should_not only_allow_numeric_values_for(:age, :allow_blank => false) }
  
  it { should only_allow_numeric_or_blank_values_for(:age) }
  
  it { should require_attributes(:owner_id) }

  it { should validate_numericality_of(:age) }
  it { should validate_numericality_of(:age).only_integer }
  it { should validate_numericality_of(:age).allow_blank(true) }
  it { should validate_numericality_of(:age).odd }
  it { should validate_numericality_of(:age).even(false) }
  it { should validate_numericality_of(:age).greater_than_or_equal_to(10) }

  it { should_not validate_numericality_of(:age, :only_integer => false) }
  it { should_not validate_numericality_of(:age, :allow_blank => false) }
  it { should_not validate_numericality_of(:age).odd(false) }
  it { should_not validate_numericality_of(:age).even }

  it { should validate_numericality_of(:owner_id) }
  it { should validate_numericality_of(:owner_id).only_integer(false) }
  it { should validate_numericality_of(:owner_id).allow_nil }
  it { should validate_numericality_of(:owner_id).odd(false) }
  it { should validate_numericality_of(:owner_id).even }

  it { should_not validate_numericality_of(:owner_id, :only_integer => true) }
  it { should_not validate_numericality_of(:owner_id, :allow_nil => false) }
  it { should_not validate_numericality_of(:owner_id).odd }
  it { should_not validate_numericality_of(:owner_id).even(false) }
end

describe Pets::Dog do
  should_belong_to :user
  should_belong_to :address
  should_belong_to :user, :address
  should_not_belong_to :foo, :bar

  should_have_and_belong_to_many :fleas

  should_only_allow_numeric_or_blank_values_for :age
  should_only_allow_numeric_values_for :age, :allow_blank => true
  should_not_only_allow_numeric_values_for :age, :allow_blank => false

  should_require_attributes :owner_id

  should_validate_numericality_of :owner_id
  should_validate_numericality_of :owner_id, :allow_nil => true
  should_validate_numericality_of :owner_id, :even => true
  should_not_validate_numericality_of :owner_id, :odd => true
  should_not_validate_numericality_of :owner_id, :allow_nil => false

  should_validate_numericality_of :age
  should_validate_numericality_of :age, :allow_blank => true
  should_validate_numericality_of :age, :odd => true
  should_not_validate_numericality_of :age, :even => true
  should_not_validate_numericality_of :age, :allow_blank => false
end
