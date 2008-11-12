require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Friendship do
  it { should belong_to(:user) }
  it { should belong_to(:friend) }
  it { should belong_to(:user, :friend) }
end

describe Friendship do
  should_belong_to :user
  should_belong_to :friend
  should_belong_to :user, :friend
end
