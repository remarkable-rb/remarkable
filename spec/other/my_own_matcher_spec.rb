require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "my own matcher" do
  it { "abc".should first_three_letters_of_alphabet }
end

def first_three_letters_of_alphabet
  simple_matcher "be the first three letters of alphabet" do |spec|
    spec.should == "abc"
  end
end
