require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Remarkable::Macros do
  subject { [1, 2, 3] }

  should_contain(1)
  should_contain(1, 2)
  should_contain(1, 2, 3)

  should_not_contain(4)
  should_not_contain(1, 4)

  describe "with disabled examples" do
    # Example disabled without parameters to ensure rescue works properly
    xshould_not_single_contain
    xshould_contain(5)
    xshould_not_contain(1)
  end

  describe "with blocks" do
    subject { [1, 2, 3] }

    should_not_single_contain(4)
    should_single_contain(4){ self << 4 }
  end
end
