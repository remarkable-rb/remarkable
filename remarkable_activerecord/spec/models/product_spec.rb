require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Product do
  describe 'when tangible' do
    before(:each){ @product = Product.new(:tangible => true) }

    it { should validate_presence_of(:title, :price) }

    it { should validate_numericality_of(:price) }
    it { should validate_numericality_of(:price).even }
    it { should validate_numericality_of(:price).odd(false) }
    it { should validate_numericality_of(:price).greater_than_or_equal_to(20) }
    it { should_not validate_numericality_of(:price).odd }
    it { should_not validate_numericality_of(:price).greater_than_or_equal_to(19) }
  end

  describe 'when untangible' do
    before(:each){ @product = Product.new(:tangible => false) }

    it { should validate_presence_of(:title) }
    it { should_not validate_presence_of(:price) }

    it { should validate_length_of(:size, :in => 3..5) }
    it { should validate_length_of(:size, :in => 3..5).allow_blank }
    it { should_not validate_length_of(:size, :within => 2..5) }
    it { should_not validate_length_of(:size, :within => 3..6) }
    it { should_not validate_length_of(:size, :within => 3..5, :allow_blank => false) }

    it { should validate_numericality_of(:price) }
    it { should validate_numericality_of(:price).odd }
    it { should validate_numericality_of(:price).even(false) }
    it { should validate_numericality_of(:price).less_than_or_equal_to(20) }
    it { should_not validate_numericality_of(:price).even }
    it { should_not validate_numericality_of(:price).less_than_or_equal_to(21) }
  end
end

describe Product do
  describe 'when tangible' do
    before(:each){ @product = Product.new(:tangible => true) }

    should_validate_presence_of :title, :price

    should_validate_numericality_of :price
    should_validate_numericality_of :price, :even => true
    should_validate_numericality_of :price, :odd => false
    should_validate_numericality_of :price, :greater_than_or_equal_to => 20
    should_not_validate_numericality_of :price, :odd => true
    should_not_validate_numericality_of :price, :greater_than_or_equal_to => 19
  end

  describe 'when untangible' do
    before(:each){ @product = Product.new(:tangible => false) }

    should_validate_presence_of :title
    should_not_validate_presence_of :price

    should_validate_length_of :size, :in => 3..5
    should_validate_length_of :size, :in => 3..5, :allow_blank => true
    should_not_validate_length_of :size, :within => 2..5
    should_not_validate_length_of :size, :within => 3..6
    should_not_validate_length_of :size, :within => 3..5, :allow_blank => false

    should_validate_numericality_of :price
    should_validate_numericality_of :price, :odd => true
    should_validate_numericality_of :price, :even => false
    should_validate_numericality_of :price, :less_than_or_equal_to => 20
    should_not_validate_numericality_of :price, :even => true
    should_not_validate_numericality_of :price, :less_than_or_equal_to => 21
  end
end
