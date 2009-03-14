require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tag do
  it { should have_many(:taggings).dependent(:destroy) }
  it { should have_many(:taggings, :dependent => :destroy) }
  it { should have_many(:posts) }

  it { should validate_length_of(:name, :minimum => 1) }
  it { should validate_length_of(:name, :minimum => 1).allow_blank }
  
  it { should allow_mass_assignment_of(:name) }
  it { should_not allow_mass_assignment_of(:secret) }
end

describe Tag do
  should_have_many :taggings, :dependent => :destroy
  should_have_many :posts

  should_validate_length_of :name, :minimum => 1
  should_validate_length_of :name, :minimum => 1, :allow_blank => true

  should_allow_mass_assignment_of :name
  should_not_allow_mass_assignment_of :secret
end
