require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  it { should validate_length_of(:ssn, :is => 9, :message => "Social Security Number is not the right length") }
  it { should validate_length_of(:ssn, :is => 9).message("Social Security Number is not the right length") }
  it { should_not validate_length_of(:ssn, :is => 9) }
  it { should_not validate_length_of(:ssn, :is => 8).message("Social Security Number is not the right length") }
  it { should_not validate_length_of(:ssn, :is => 10).message("Social Security Number is not the right length") }
end

describe User do
  should_validate_length_of :ssn, :is => 9, :message => "Social Security Number is not the right length"
  should_not_validate_length_of :ssn, :is => 9
  should_not_validate_length_of :ssn, :is => 8, :message => "Social Security Number is not the right length"
  should_not_validate_length_of :ssn, :is => 10, :message => "Social Security Number is not the right length"
end
