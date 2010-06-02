# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Remarkable::DSL::Optionals do

  describe "without config blocks" do

    before(:each) do
      @matcher = Remarkable::RSpec::Matchers::BeAPersonMatcher.new
    end

    describe "as optionals" do
      it "should allow optionals to be set" do
        @matcher.first_name('José')
        @matcher.options[:first_name].should == 'José'

        @matcher.last_name('Valim')
        @matcher.options[:last_name].should == 'Valim'
      end

      it "should allow defaults values" do
        @matcher.age
        @matcher.options[:age].should == 18
      end

      it "should allow alias to be set" do
        @matcher.family_name('Valim')
        @matcher.options[:last_name].should == 'Valim'
      end

      it "should allow multiple options to be given" do
        @matcher.bands(:incubus, :foo_fighters)
        @matcher.options[:bands].should == [:incubus, :foo_fighters]
      end

      it "should allow multiple options to be appended once at a time" do
        @matcher.bands(:incubus)
        @matcher.bands(:foo_fighters)
        @matcher.options[:bands].should == [:incubus, :foo_fighters]
      end

      it "should allow blocks to given to options" do
        @matcher.builder {|i| i + 10 }
        @matcher.options[:builder].call(10).should == 20

        @matcher.builder proc{|i| i + 20 }
        @matcher.options[:builder].call(10).should == 30
      end
    end

    describe "as optionals=" do
      it "should allow optionals to be set" do
        @matcher.first_name = 'José'
        @matcher.options[:first_name].should == 'José'

        @matcher.last_name = 'Valim'
        @matcher.options[:last_name].should == 'Valim'
      end

      it "should allow alias to be set" do
        @matcher.family_name = 'Valim'
        @matcher.options[:last_name].should == 'Valim'
      end

      it "should allow multiple options to be given" do
        @matcher.bands = [ :incubus, :foo_fighters ]
        @matcher.options[:bands].should == [ :incubus, :foo_fighters ]
      end

      it "should overwrite previous options" do
        @matcher.bands = [ :incubus ]
        @matcher.bands = [ :foo_fighters ]
        @matcher.options[:bands].should == [:foo_fighters]
      end

      it "should allow blocks to given to options" do
        @matcher.builder = proc{|i| i + 20 }
        @matcher.options[:builder].call(10).should == 30
      end
    end

  end

  describe "with config blocks" do

    def builder(*args, &block)
      Remarkable::RSpec::Matchers::BeAPersonMatcher.new(*args, &block)
    end

    describe "as optionals" do
      it "should allow optionals to be set" do
        matcher = builder do |m|
          m.first_name 'José'
          m.last_name 'Valim'
        end

        matcher.options[:first_name].should == 'José'
        matcher.options[:last_name].should == 'Valim'
      end

      it "should allow defaults values" do
        matcher = builder do |m|
          m.age
        end

        matcher.options[:age].should == 18
      end

      it "should allow alias to be set" do
        matcher = builder do |m|
          m.family_name 'Valim'
        end

        matcher.options[:last_name].should == 'Valim'
      end

      it "should allow multiple options to be given" do
        matcher = builder do |m|
          m.bands(:incubus, :foo_fighters)
        end

        matcher.options[:bands].should == [:incubus, :foo_fighters]
      end

      it "should allow multiple options to be appended once at a time" do
        matcher = builder do |m|
          m.bands(:incubus)
          m.bands(:foo_fighters)
        end

        matcher.options[:bands].should == [:incubus, :foo_fighters]
      end

      it "should allow blocks to given to options" do
        matcher = builder do |m|
          m.builder {|i| i + 10 }
        end

        matcher.options[:builder].call(10).should == 20

        matcher = builder do |m|
          m.builder proc {|i| i + 20 }
        end

        matcher.options[:builder].call(10).should == 30
      end
    end

    describe "as optionals=" do
      it "should allow optionals to be set" do
        matcher = builder do |m|
          m.first_name = 'José'
          m.last_name = 'Valim'
        end

        matcher.options[:first_name].should == 'José'
        matcher.options[:last_name].should == 'Valim'
      end

      it "should allow alias to be set" do
        matcher = builder do |m|
          m.family_name = 'Valim'
        end

        matcher.options[:last_name].should == 'Valim'
      end

      it "should allow multiple options to be given" do
        matcher = builder do |m|
          m.bands = [ :incubus, :foo_fighters ]
        end

        matcher.options[:bands].should == [ :incubus, :foo_fighters ]
      end

      it "should overwrite previous options" do
        matcher = builder do |m|
          m.bands = [ :incubus ]
          m.bands = [ :foo_fighters ]
        end

        matcher.options[:bands].should == [ :foo_fighters ]
      end

      it "should allow blocks to given to options" do
        matcher = builder do |m|
          m.builder = proc {|i| i + 20 }
        end

        matcher.options[:builder].call(10).should == 30
      end
    end

  end

  describe "description" do
    it "should provide a description with optionals" do
      matcher = Remarkable::RSpec::Matchers::SingleContainMatcher.new(1)
      matcher.description.should == 'contain 1 not checking for blank'

      matcher.allow_blank(10)
      matcher.description.should == 'contain 1 with blank equal 10'

      matcher.allow_blank(true)
      matcher.description.should == 'contain 1 with blank equal true'

      matcher.allow_nil(true)
      matcher.description.should == 'contain 1 allowing nil and with blank equal true'

      matcher.allow_nil(false)
      matcher.description.should == 'contain 1 not allowing nil and with blank equal true'
    end

    it "should provide a sentence interpolation option to optionals" do
      matcher = Remarkable::RSpec::Matchers::SingleContainMatcher.new(1)
      matcher.values(1, 2, 3)
      matcher.description.should == 'contain 1 not checking for blank and values equal to 1, 2, and 3'
    end

    it "should inspect values in sentence interpolation options" do
      matcher = Remarkable::RSpec::Matchers::SingleContainMatcher.new(1)
      matcher.values(:a, :b, :c)
      matcher.description.should == 'contain 1 not checking for blank and values equal to :a, :b, and :c'
    end

    it "should provide a description with optionals through namespace lookup" do
      matcher = Remarkable::RSpec::Matchers::CollectionContainMatcher.new(1)
      matcher.description.should == 'contain 1'

      matcher.allow_nil(true)
      matcher.description.should == 'contain 1 allowing nil'

      matcher.allow_nil(false)
      matcher.description.should == 'contain 1 not allowing nil'
    end
  end
end
