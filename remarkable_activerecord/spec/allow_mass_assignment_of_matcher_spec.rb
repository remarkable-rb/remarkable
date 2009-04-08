require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'allow_mass_assignment_of' do
  include ModelBuilder

  def define_and_validate(options={})
    @model = define_model :product, :title => :string, :category => :string do
      attr_protected  :title, :category     if options[:protected]

      attr_accessible :title, :category     if options[:accessible] == true
      attr_accessible *options[:accessible] if options[:accessible].is_a?(Array)
    end

    allow_mass_assignment_of(:title, :category)
  end

  describe 'messages' do

    it 'should contain a description' do
      @matcher = allow_mass_assignment_of(:title, :category)
      @matcher.description.should == 'allow mass assignment of title and category'
    end

    it 'should set is_protected? missing message' do
      @matcher = define_and_validate(:protected => true)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to allow mass assignment of title (Product is protecting title)'
    end

    it 'should set is_accessible? missing message' do
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
  end

  describe 'macros' do
    before(:each){ define_and_validate(:accessible => true) }

    should_allow_mass_assignment_of :title
    should_allow_mass_assignment_of :category
    should_allow_mass_assignment_of :title, :category

    should_not_allow_mass_assignment_of :another
    should_not_allow_mass_assignment_of :title, :another
  end
end

