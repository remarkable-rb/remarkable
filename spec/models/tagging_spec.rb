require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tagging do
  it { Tagging.should belong_to(:post) }
  it { Tagging.should belong_to(:tag) }
end
