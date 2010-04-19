require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'allow_mass_assignment_of' do
  include ModelBuilder

  def define_and_validate(options={})
    @model = define_model :product, :title => :string, :category => :string do
      attr_protected  :title, :category     if options[:protected]

      attr_accessible :title, :category     if options[:accessible] == true
      attr_accessible                       if options[:accessible] == false
      attr_accessible *options[:accessible] if options[:accessible].is_a?(Array)
    end

    allow_mass_assignment_of(:title, :category)
  end

  describe 'messages' do

    it 'should contain a description' do
      @matcher = allow_mass_assignment_of(:title, :category)
      @matcher.description.should == 'allow mass assignment of title and category'
    end

    it 'should set allows? message' do
      define_and_validate(:protected => true)
      @matcher = allow_mass_assignment_of
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow mass assignment (Product is protecting category and title)'
    end

    it 'should set is_protected? message' do
      @matcher = define_and_validate(:protected => true)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow mass assignment of title (Product is protecting title)'
    end

    it 'should set is_accessible? message' do
      @matcher = define_and_validate(:accessible => [:another])
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow mass assignment of title (Product has not made title accessible)'
    end

  end

  describe 'matchers' do
    it { should define_and_validate }
    it { should define_and_validate(:accessible => true) }

    it { should_not define_and_validate(:protected => true) }
    it { should_not define_and_validate(:accessible => [:another]) }

    describe 'with no argument' do
      it 'should allow mass assignment if no attribute is accessible or protected' do
        define_and_validate
        should allow_mass_assignment_of
      end

      it 'should allow mass assignment if attributes are accessible' do
        define_and_validate(:accessible => true)
        should allow_mass_assignment_of
      end

      it 'should not allow mass assignment if attributes are protected' do
        define_and_validate(:protected => true)
        should_not allow_mass_assignment_of
      end
      
      it 'should not allow mass assignment if all attributes are protected by default' do
        define_and_validate(:accessible => false)
        should allow_mass_assignment_of
        should_not allow_mass_assignment_of :title
        should_not allow_mass_assignment_of :category
      end
    end
  end

  describe 'macros' do
    before(:each){ define_and_validate(:accessible => true) }

    should_allow_mass_assignment_of :title
    should_allow_mass_assignment_of :category
    should_allow_mass_assignment_of :title, :category

    should_not_allow_mass_assignment_of :another
  end

  describe 'failures' do
    it "should fail if some attribute is accessible when it should be protected" do
      define_and_validate(:accessible => true)

      lambda {
        should_not allow_mass_assignment_of :title, :another
      }.should raise_error(Rspec::Expectations::ExpectationNotMetError, /Product has made title accessible/)
    end

    it "should fail if attributes are accessible when none should" do
      define_and_validate(:accessible => true)

      lambda {
        should_not allow_mass_assignment_of
      }.should raise_error(Rspec::Expectations::ExpectationNotMetError, /Product made category and title accessible/)
    end

    it "should fail if nothing was declared but expected to be protected" do
      define_and_validate

      lambda {
        should_not allow_mass_assignment_of(:title)
      }.should raise_error(Rspec::Expectations::ExpectationNotMetError, /Did not expect Product to allow mass assignment of title/)
    end
  end
end

