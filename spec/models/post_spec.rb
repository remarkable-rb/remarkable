require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Post do
  fixtures :all

  it { should belong_to(:user) }
  it { should belong_to(:owner) }
  it { should belong_to(:user, :owner) }
  
  it { should have_many(:tags).through(:taggings) }
  it { should have_many(:tags, :through => :taggings) }

  it { should have_many(:through_tags).through(:taggings) }
  it { should have_many(:through_tags, :through => :taggings) }

  it { should have_many(:tags, :through_tags).through(:taggings) }
  it { should have_many(:tags, :through_tags, :through => :taggings) }

  it { should require_unique_attributes(:title) }
  it { should_not require_unique_attributes(:body) }
  it { should_not require_unique_attributes(:title).scoped_to(:user_id) }
  it { should_not require_unique_attributes(:title, :scoped_to => :user_id) }
  
  it { should require_attributes(:body, :message => /wtf/) }
  it { should_not require_attributes(:body) }
  it { should require_attributes(:title) }
  it { should_not require_attributes(:user_id) }
  
  it { should only_allow_numeric_values_for(:user_id) }
end

describe Post do
  fixtures :all

  should_belong_to :user
  should_belong_to :owner
  should_belong_to :user, :owner
  
  should_have_many :tags, :through => :taggings
  should_have_many :through_tags, :through => :taggings
  should_have_many :tags, :through_tags, :through => :taggings
  
  should_require_unique_attributes :title
  should_require_attributes :body, :message => /wtf/
  should_require_attributes :title
  should_only_allow_numeric_values_for :user_id
end
