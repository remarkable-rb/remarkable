require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dog do
  it { should belong_to(:user) }
  it { should belong_to(:address) }
  it { should have_and_belong_to_many(:fleas) }
end

describe Dog do
  should_belong_to :user
  should_belong_to :address
  should_belong_to :user, :address

  should_have_and_belong_to_many :fleas
end
