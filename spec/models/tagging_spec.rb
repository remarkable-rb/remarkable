require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tagging do
  it { should belong_to(:post) }
  it { should belong_to(:tag) }
  it { should belong_to(:post, :tag) }
end
