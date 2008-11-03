require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Friendship do
  it { Friendship.should belong_to(:user) }
  it { Friendship.should belong_to(:friend) }
end
