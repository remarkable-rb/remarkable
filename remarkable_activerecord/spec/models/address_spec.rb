require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do
  it { should validate_length_of(:zip, :minimum => 5) }
  it { should validate_length_of(:zip, :minimum => 5).allow_nil }
  it { should_not validate_length_of(:zip, :is => 5) }
  it { should_not validate_length_of(:zip, :minimum => 4) }
  it { should_not validate_length_of(:zip, :minimum => 6) }
end

describe Address do
  should_validate_length_of :zip, :minimum => 5
  should_validate_length_of :zip, :minimum => 5, :allow_nil => true
  should_not_validate_length_of :zip, :is => 5
  should_not_validate_length_of :zip, :minimum => 4
  should_not_validate_length_of :zip, :minimum => 6
end
