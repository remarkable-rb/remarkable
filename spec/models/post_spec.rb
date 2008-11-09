require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Post do
  fixtures :all
  
  it { Post.should belong_to(:user) }
  it { Post.should belong_to(:owner) }
  it { Post.should belong_to(:user, :owner) }
  
  it { Post.should have_many(:tags, :through => :taggings) }
  it { Post.should have_many(:through_tags, :through => :taggings) }
  it { Post.should have_many(:tags, :through_tags, :through => :taggings) }

  it { Post.should require_unique_attributes(:title) }
  it { Post.should require_attributes(:body, :message => /wtf/) }
  it { Post.should require_attributes(:title) }
  it { Post.should only_allow_numeric_values_for(:user_id) }
end
