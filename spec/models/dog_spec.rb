require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dog do
  it { should belong_to(:user) }
  it { should belong_to(:address) }
  it { should belong_to(:user, :address) }
  it { should_not belong_to(:foo, :bar) }
  
  it { should have_and_belong_to_many(:fleas) }
  
  it { should only_allow_numeric_values_for(:age).allow_blank }
  it { should only_allow_numeric_values_for(:age).allow_blank(true) }
  it { should only_allow_numeric_values_for(:age, :allow_blank => true) }
  
  it { should_not only_allow_numeric_values_for(:age) }
  it { should_not only_allow_numeric_values_for(:age).allow_blank(false) }
  it { should_not only_allow_numeric_values_for(:age, :allow_blank => false) }
  
  it { should only_allow_numeric_or_blank_values_for(:age) }
end

describe Dog do
  should_belong_to :user
  should_belong_to :address
  should_belong_to :user, :address
  should_not_belong_to :foo, :bar

  should_have_and_belong_to_many :fleas
  
  should_only_allow_numeric_values_for :age, :allow_blank => true
  should_not_only_allow_numeric_values_for :age
  should_not_only_allow_numeric_values_for :age, :allow_blank => false
  
  should_only_allow_numeric_or_blank_values_for :age
end
