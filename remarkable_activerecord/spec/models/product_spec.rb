require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Product do
  describe 'when tangible' do
    before(:each){ @product = Product.new(:tangible => true) }

    it { should validate_presence_of(:title, :price) }
  end

  describe 'when untangible' do
    before(:each){ @product = Product.new(:tangible => false) }

    it { should validate_presence_of(:title) }
    it { should_not validate_presence_of(:price) }
  end
end

describe Product do
  describe 'when tangible' do
    before(:each){ @product = Product.new(:tangible => true) }

    should_validate_presence_of :title, :price
  end

  describe 'when untangible' do
    before(:each){ @product = Product.new(:tangible => false) }

    should_validate_presence_of :title
    should_not_validate_presence_of :price
  end
end
