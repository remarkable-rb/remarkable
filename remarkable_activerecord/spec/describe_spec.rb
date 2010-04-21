require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Post
  attr_accessor :published, :public, :deleted
 
  def attributes=(attributes={}, guard=true)
    attributes.each do |key, value|
      send(:"#{key}=", value) unless guard
    end
  end

end

describe Remarkable::ActiveRecord do
  describe "#humanize_subject_attributes" do
    it "should generate a list of human attribute names" do
      self.class.send(:humanize_subject_attributes, Post, {:published => true}).should include('published is true')
    end
    it "should humanize attribute names" do
      Post.should_receive(:human_attribute_name).and_return('my_published')
      self.class.send(:humanize_subject_attributes, Post, {:published => true}).should include('my_published is true')
    end
  end
end

describe Post do
  before(:each) do
    #model_name = mock(:model_name)
    #model_name.stub!(:human).and_return('MyPost')
    #self.described_class.stub!(:model_name).and_return(model_name)
  end

  it "should set the subject class" do
    self.described_class.should eql(subject.class)
  end

  describe "when using nested examples" do
    it "should set the subject class" do
      self.described_class.should eql(subject.class)
    end
  end

  it "should use human name on description" do
    self.class.description.should == "MyPost"
  end

  describe "default attributes as a hash" do
    subject_attributes :deleted => true

    it "should set the subject with deleted equals to true" do
      subject.deleted.should be_true
    end

    it "should not change the description" do
      self.class.description.should == "default attributes as a hash"
    end
  end

  describe "default attributes as a proc" do
    subject_attributes { my_attributes }

    def my_attributes
      { :deleted => true }
    end

    it "should set the subject with deleted equals to true" do
      subject_attributes.should eql(my_attributes)
      subject.deleted.should be_true
    end

    it "should not change the description" do
      self.class.description.should == "default attributes as a proc"
    end
  end

  describe :published => true do
    it "should set the subject with published equals to true" do
      subject.published.should be_true
    end

    it "should generate a readable description" do
      self.class.description.should == "MyPost when published is true"
    end

    it "should call human name attribute on the described class" do
      Post.should_receive(:human_attribute_name).with("comments_count", :locale => :en).and_return("__COMMENTS__COUNT__")
      self.class.describe(:comments_count => 5) do
        self.description.should == 'MyPost when published is true and __comments__count__ is 5'
      end
    end

    describe :public => false do
      it "should nest subject attributes" do
        subject.published.should be_true
        subject.public.should be_false
      end

      it "should nest descriptions" do
        self.class.description.should == "MyPost when published is true and public is false"
      end

      describe "default attributes as a hash" do
        subject_attributes :deleted => true

        it "should merge describe attributes with subject attributes" do
          subject_attributes.should include(:deleted)

          subject.published.should be_true
          subject.public.should be_false
          subject.deleted.should be_true
        end
      end
    end
  end

  describe :published => true, :public => false do
    it "should set the subject with published equals to true and public equals to false" do
      subject.published.should be_true
      subject.public.should be_false
    end

    it "should include both published and public in descriptions" do
      self.class.description.should match(/MyPost/)
      self.class.description.should match(/public is false/)
      self.class.description.should match(/published is true/)
    end
  end
end
