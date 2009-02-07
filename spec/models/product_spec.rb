require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Product do
  it { should require_attributes(:title) }
  it { should_not require_attributes(:price) }
  
  describe "An intangible product" do
    before(:all) do
      @product = Product.new(:tangible => false)
    end

    it { @product.should_not allow_values_for(:size, "22") }
    it { @product.should allow_values_for(:size, "22kb") }

    it { @product.should validate_exclusion_of(:weight, 10..100) }
    it { @product.should_not validate_exclusion_of(:weight, 1..9) }
    
    it { @product.should require_attributes(:title) }
    it { @product.should_not require_attributes(:price) }

    it { @product.should validate_presence_of(:title) }
    it { @product.should_not validate_presence_of(:price) }
    
    it { @product.should ensure_value_in_range(:price, 0..99) }
  end

  describe "A tangible product" do
    before(:all) do
      @product = Product.new(:tangible => true)
    end

    it { @product.should_not allow_inclusion_of(:size, "XXXL", "XXL") }
    it { @product.should allow_inclusion_of(:size, "S", "M", "L", "XL") }

    it { @product.should_not validate_inclusion_of(:size, "XXXL", "XXL") }
    it { @product.should validate_inclusion_of(:size, "S", "M", "L", "XL") }

    it { @product.should validate_exclusion_of(:size, "XS", "XM") }
    it { @product.should_not validate_exclusion_of(:size, "S", "M", "L", "XL") }

    it { @product.should require_attributes(:price, :title) }
    it { @product.should validate_presence_of(:price, :title) }

    it { @product.should ensure_value_in_range(:price, 1..9999) }
    it { @product.should ensure_value_in_range(:weight, 1..100) }

    it { @product.should validate_inclusion_of(:price, 1..9999) }
    it { @product.should validate_inclusion_of(:weight, 1..100) }

    it { @product.should ensure_length_in_range(:size, 5..20) }
  end
end

describe Product do
  describe "An intangible product" do
    before(:all) do
      @product = Product.new(:tangible => false)
    end

    should_not_allow_values_for :size, "22"
    should_allow_values_for :size, "22kb"
    
    should_ensure_value_in_range :price, 0..99

    should_require_attributes(:title)
    should_not_require_attributes(:price)

    should_validate_presence_of(:title)
    should_not_validate_presence_of(:price)
  end

  describe "A tangible product" do
    before(:all) do
      @product = Product.new(:tangible => true)
    end

    should_not_allow_inclusion_of :size, "XXXL", "XXL"
    should_allow_inclusion_of :size, "S", "M", "L", "XL"

    should_not_validate_inclusion_of :size, "XXXL", "XXL"
    should_validate_inclusion_of :size, "S", "M", "L", "XL"

    should_ensure_exclusion_of :size, "XS", "XM"
    should_not_ensure_exclusion_of :size, "S", "M", "L", "XL"

    should_validate_exclusion_of :size, "XS", "XM"
    should_not_validate_exclusion_of :size, "S", "M", "L", "XL"

    should_require_attributes(:price, :title)
    should_validate_presence_of(:price, :title)

    should_ensure_value_in_range :price, 1..9999
    should_ensure_value_in_range :weight, 1..100

    should_validate_inclusion_of :price, 1..9999
    should_validate_inclusion_of :weight, 1..100

    should_ensure_length_in_range :size, 5..20
  end
end
