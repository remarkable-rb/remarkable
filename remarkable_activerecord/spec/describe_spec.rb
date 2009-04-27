require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

RAILS_I18n = true

class Post
  attr_accessor :title, :published, :public
 
  def initialize(attributes={})
    attributes.each do |key, value|
      send(:"#{key}=", value)
    end
  end

  def self.human_name(*args)
    "MyPost"
  end
end unless defined?(Post)

describe Post do
  it "should use human name on description" do
    self.class.description.should == "MyPost"
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
