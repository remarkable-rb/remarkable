require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tag do
  it { Tag.should have_many(:taggings, :dependent => :destroy) }
  it { Tag.should have_many(:posts) }

  it { Tag.should ensure_length_at_least(:name, 2) }

  it { Tag.should protect_attributes(:secret) }

  it { Tag.should_not protect_attributes(:name) }
end
