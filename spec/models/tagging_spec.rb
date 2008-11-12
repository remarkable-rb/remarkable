require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tagging do
  it { should belong_to(:post) }
  it { should belong_to(:tag) }
  it { should belong_to(:post, :tag) }
end

describe Tagging do
  should_belong_to :post
  should_belong_to :tag
  should_belong_to :post, :tag
end
