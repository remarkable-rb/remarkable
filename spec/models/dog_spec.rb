require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dog do
  it { Dog.should belong_to(:user) }
  it { Dog.should belong_to(:address) }

  # should_have_and_belong_to_many :fleas
end
