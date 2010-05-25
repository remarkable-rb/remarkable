require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Remarkable, 'pending examples' do

  it "should create pending groups" do
    spec = self

    self.class.pending "pending examples" do
      self.instance_variable_get("@_pending_group").should spec.be_true
      self.instance_variable_get("@_pending_group_description").should spec.eql("pending examples")
      self.instance_variable_get("@_pending_group_execute").should spec.be_true
    end

    self.instance_variable_get("@_pending_group").should be_nil
    self.instance_variable_get("@_pending_group_description").should be_nil
    self.instance_variable_get("@_pending_group_execute").should be_nil
  end

  pending "pending examples" do
#    example "should show as not implemented"
#
#    specify "should show as pending" do
#      raise "oops"
#    end
#
#    it "should show as fixed" do
#      true.should be_true
#    end

    should_contain(5)
  end

end
