require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tag do
  it { Tag.should have_many(:taggings, :dependent => :destroy) }
  it { Tag.should have_many(:posts) }
  
  it { Tag.should ensure_length_at_least(:name, 2) }
  
  # should_protect_attributes :secret
  # 
  # should_fail do
  #   should_protect_attributes :name
  # end
end
