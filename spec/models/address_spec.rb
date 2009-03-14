require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do
  fixtures :all

  it { should belong_to(:addressable) }
  
  it { should validate_uniqueness_of(:title, :scope => [:addressable_id, :addressable_type]) }
  it { should validate_uniqueness_of(:title).scope([:addressable_id, :addressable_type]) }
  it { should_not validate_uniqueness_of(:title, :scope => [:addressable_id]) }
  it { should_not validate_uniqueness_of(:zip) }
  
  it { should validate_length_of(:zip, :minimum => 5) }
  it { should validate_length_of(:zip, :minimum => 5).allow_nil }
  it { should_not validate_length_of(:zip, :is => 5) }
  it { should_not validate_length_of(:zip, :minimum => 5, :allow_nil => false) }
  it { should_not validate_length_of(:zip, :minimum => 4) }
  it { should_not validate_length_of(:zip, :minimum => 6) }

  it { proc{ should validate_length_of(:zip) }.should raise_error }

  it { should validate_numericality_of(:zip) }
  it { should validate_numericality_of(:zip).less_than(20) }
  it { should validate_numericality_of(:zip).greater_than(10) }
  it { should validate_numericality_of(:zip).less_than(20).greater_than(10) }
  it { should_not validate_numericality_of(:title) }
  it { should_not validate_numericality_of(:zip, :less_than => 10) }
  it { should_not validate_numericality_of(:zip, :greater_than => 20) }
end

describe Address do
  fixtures :all

  should_belong_to :addressable

  should_validate_uniqueness_of :title, :scope => [:addressable_id, :addressable_type]
  should_not_validate_uniqueness_of :zip
  
  should_validate_length_of :zip, :minimum => 5
  should_validate_length_of :zip, :minimum => 5, :allow_nil => true
  should_not_validate_length_of :zip, :minimum => 5, :allow_nil => false
  should_not_validate_length_of :zip, :is => 5
  should_not_validate_length_of :zip, :minimum => 4
  should_not_validate_length_of :zip, :minimum => 6
  
  should_validate_numericality_of :zip
  should_validate_numericality_of :zip, :less_than => 20
  should_validate_numericality_of :zip, :greater_than => 10
  should_validate_numericality_of :zip, :less_than => 20, :greater_than => 10
  should_not_validate_numericality_of :title
  should_not_validate_numericality_of :zip, :less_than => 10
  should_not_validate_numericality_of :zip, :greater_than => 20
end
