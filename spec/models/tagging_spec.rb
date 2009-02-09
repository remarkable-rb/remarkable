require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tagging do
  it { should belong_to(:post) }
  it { should belong_to(:tag) }
  it { should belong_to(:post, :tag) }

  it { should validate_associated(:post) }
  it { should validate_associated(:tag) }
  it { should validate_associated(:tag, :post) }

  it do
    # Create a Post mock that will return true when saving.
    # This means that the object Post is always valid, then it can not be validated.
    @post = mock_model(Post, :save => true, :valid? => true)
    should_not validate_associated(:post)
  end

  it do
    # Create a Tagging mock that will return true when saving.
    # This means that even the association :post is not valid, :tagging will be valid.
    # Then the association is not validated.
    @tagging = Tagging.new
    @tagging.stub!(:save).and_return(true)
    should_not validate_associated(:post)
  end
end

describe Tagging do
  should_belong_to :post
  should_belong_to :tag
  should_belong_to :post, :tag

  should_validate_associated :tag
  should_validate_associated :post
  should_validate_associated :tag, :post
end
