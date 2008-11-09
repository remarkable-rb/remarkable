require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do
  fixtures :all

  it { Address.should belong_to(:addressable) }
  
  it { Address.should require_unique_attributes(:title, :scoped_to => [:addressable_id, :addressable_type]) }
  it { Address.should ensure_length_at_least(:zip, 5) }
  it { Address.should only_allow_numeric_values_for(:zip) }
end
