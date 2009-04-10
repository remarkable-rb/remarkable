require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Remarkable::Macros do

  describe "with pending examples" do
    pending "pending examples" do
      should_contain(5)
      it("should not be run"){ true.should be_false }
    end
  end

end
