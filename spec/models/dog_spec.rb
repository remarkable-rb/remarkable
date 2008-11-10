require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dog do
  it { should belong_to(:user) }
  it { should belong_to(:address) }
  it { should belong_to(:user, :address) }

  it { should have_and_belong_to_many(:fleas) }
end
