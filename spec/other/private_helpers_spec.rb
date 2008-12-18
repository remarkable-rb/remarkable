# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# 
# describe "PrivateHelpers" do
#   describe "get_options!" do
#     it "remove opts from args" do
#       args = [:a, :b, {}]
#       get_options!(args)
#       args.should == [:a, :b]
#     end
# 
#     it "return wanted opts in order" do
#       args = [{:one => 1, :two => 2}]
#       one, two = get_options!(args, :one, :two)
#       one.should == 1
#       two.should == 2
#     end
# 
#     it "raise ArgumentError if given unwanted option" do
#       args = [{:one => 1, :two => 2}]
#       lambda { get_options!(args, :one) }.should raise_error(ArgumentError)
#     end
#   end
# 
#   class ::SomeModel; end
#   describe "model_class" do
#     it "sniff the class constant from the test class" do
#       self.should_receive(:described_type).and_return(SomeModel)
#       model_class.should == SomeModel
#     end
#   end
# end
