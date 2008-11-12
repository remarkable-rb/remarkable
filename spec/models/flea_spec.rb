require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Flea do
  it { should have_and_belong_to_many(:dogs) }
end

describe Flea do
  should_have_and_belong_to_many :dogs
end
