require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Flea do
  it { should have_and_belong_to_many(:dogs) }
  describe "with valid attributes" do
    subject { Flea.new(:name => 'Mike') }
    it { should be_valid }
  end
end

describe Flea do
  should_have_and_belong_to_many :dogs
end
