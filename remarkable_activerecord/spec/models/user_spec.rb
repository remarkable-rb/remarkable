require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  it { should validate_length_of(:ssn, :is => 9, :message => "Social Security Number is not the right length") }
  it { should validate_length_of(:ssn, :is => 9).message("Social Security Number is not the right length") }
  it { should_not validate_length_of(:ssn, :is => 9) }
  it { should_not validate_length_of(:ssn, :is => 8).message("Social Security Number is not the right length") }
  it { should_not validate_length_of(:ssn, :is => 10).message("Social Security Number is not the right length") }
  
  it { should validate_numericality_of(:ssn) }
  it { should validate_numericality_of(:ssn).allow_blank }
  it { should validate_numericality_of(:ssn).equal_to(123456789) }
  it { should_not validate_numericality_of(:age) }
  it { should_not validate_numericality_of(:ssn).allow_blank(false) }
  it { should_not validate_numericality_of(:ssn).equal_to(123456788) }
  it { should_not validate_numericality_of(:ssn).equal_to(123456790) }
end

describe User do
  should_validate_length_of :ssn, :is => 9, :message => "Social Security Number is not the right length"
  should_not_validate_length_of :ssn, :is => 9
  should_not_validate_length_of :ssn, :is => 8, :message => "Social Security Number is not the right length"
  should_not_validate_length_of :ssn, :is => 10, :message => "Social Security Number is not the right length"

  should_validate_numericality_of :ssn
  should_validate_numericality_of :ssn, :allow_blank => true
  should_validate_numericality_of :ssn, :equal_to => 123456789
  should_not_validate_numericality_of :age
  should_not_validate_numericality_of :ssn, :allow_blank => false
  should_not_validate_numericality_of :ssn, :equal_to => 123456788
  should_not_validate_numericality_of :ssn, :equal_to => 123456790
end
