require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Flea do
  fixtures :fleas
  
  it { should have_and_belong_to_many(:dogs) }
  
  describe "with valid attributes" do
    subject { Flea.new(:name => 'Mike') }
    it { should be_valid }
  end
  
  describe "without a name" do
    subject { Flea.new(:name => '') }
    it { should_not be_valid }
  end
  
  it { should validate_uniqueness_of :name, :case_sensitive => false }
end

describe Flea do
  fixtures :fleas
  
  should_have_and_belong_to_many :dogs
  
  should_validate_uniqueness_of :name, :case_sensitive => false
end
