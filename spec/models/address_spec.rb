require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do
  fixtures :all

  it { should belong_to(:addressable) }
  
  it { should require_unique_attributes(:title, :scoped_to => [:addressable_id, :addressable_type]) }
  it { should require_unique_attributes(:title).scoped_to([:addressable_id, :addressable_type]) }
  it { should_not require_unique_attributes(:title, :scoped_to => [:addressable_id]) }
  it { should_not require_unique_attributes(:zip) }
  
  it { should ensure_length_at_least(:zip, 5) }
  it { should_not ensure_length_at_least(:zip, 4) }
  it { should_not ensure_length_at_least(:zip, 6) }
  
  it { should only_allow_numeric_values_for(:zip) }
  it { should_not only_allow_numeric_values_for(:title) }
  
  it { should_not only_allow_numeric_or_blank_values_for(:zip) }
end

describe Address do
  fixtures :all

  should_belong_to :addressable
  
  should_require_unique_attributes :title, :scoped_to => [:addressable_id, :addressable_type]
  should_not_require_unique_attributes :zip
  
  should_ensure_length_at_least :zip, 5
  should_not_ensure_length_at_least :zip, 4
  should_not_ensure_length_at_least :zip, 6
  
  should_only_allow_numeric_values_for :zip
  should_not_only_allow_numeric_values_for :title
  
  should_not_only_allow_numeric_or_blank_values_for :zip
end
