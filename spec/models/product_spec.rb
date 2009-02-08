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

    it { @product.should_not validate_format_of(:size, "22") }
    it { @product.should validate_format_of(:size, "22kb") }

    it { @product.should validate_exclusion_of(:weight, 10..100) }
    it { @product.should_not validate_exclusion_of(:weight, 1..9) }

    it { @product.should require_attributes(:title) }
    it { @product.should_not require_attributes(:price) }

    it { @product.should validate_presence_of(:title) }
    it { @product.should_not validate_presence_of(:price) }
    
    it { @product.should ensure_value_in_range(:price, 0..99) }
    it { @product.should validate_inclusion_of(:price, 0..99) }
    it { @product.should validate_inclusion_of(:price, 0..99).allow_nil(false) }
    it { @product.should validate_inclusion_of(:price, 0..99).allow_blank(false) }

    it { @product.should_not ensure_value_in_range(:price, 2..80) }
    it { @product.should_not validate_inclusion_of(:price, 2..80) }
    it { @product.should_not validate_inclusion_of(:price, 0..99, :allow_nil => true) }
    it { @product.should_not validate_inclusion_of(:price, 0..99, :allow_blank => true) }
  end

  describe "A tangible product" do
    before(:all) do
      @product = Product.new(:tangible => true)
    end

    it { @product.should allow_inclusion_of(:size, "S", "M", "L", "XL") }
    it { @product.should_not allow_inclusion_of(:size, "XXXL", "XXL") }

    it { @product.should validate_inclusion_of(:size, "S", "M", "L", "XL") }
    it { @product.should validate_inclusion_of(:size, "S", "M", "L", "XL").allow_blank }
    it { @product.should_not validate_inclusion_of(:size, "XXXL", "XXL") }
    it { @product.should_not validate_inclusion_of(:size, "S", "M", "L", "XL", :allow_blank => false) }

    it { @product.should validate_exclusion_of(:size, "XS", "XM") }
    it { @product.should_not validate_exclusion_of(:size, "S", "M", "L", "XL") }

    it { @product.should require_attributes(:price, :title) }
    it { @product.should validate_presence_of(:price, :title) }

    it { @product.should ensure_value_in_range(:price, 1..9999) }
    it { @product.should ensure_value_in_range(:weight, 1..100) }

    it { @product.should validate_inclusion_of(:price, 1..9999) }
    it { @product.should validate_inclusion_of(:price, 1..9999).allow_nil }
    it { @product.should_not validate_inclusion_of(:price, 1..9999, :allow_nil => false) }

    it { @product.should validate_inclusion_of(:weight, 1..100) }
    it { @product.should validate_inclusion_of(:weight, 1..100).allow_blank(true) }
    it { @product.should_not validate_inclusion_of(:weight, 1..100, :allow_blank => false) }

    it { @product.should ensure_length_in_range(:size, 5..20) }
    it { @product.should validate_length_of(:size, :in => 5..20).allow_blank }
    it { @product.should_not validate_length_of(:size, :in => 1..10) }
    it { @product.should_not validate_length_of(:size, :within => 5..20, :allow_blank => false) }
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

    should_allow_inclusion_of :size, "S", "M", "L", "XL"
    should_not_allow_inclusion_of :size, "XXXL", "XXL"
    should_validate_inclusion_of :size, "S", "M", "L", "XL"
    should_validate_inclusion_of :size, :allow_blank => true
    should_not_validate_inclusion_of :size, "XXXL", "XXL"
    should_not_validate_inclusion_of :size, "S", "M", "L", "XL", :allow_blank => false

    should_ensure_exclusion_of :size, "XS", "XM"
    should_not_ensure_exclusion_of :size, "S", "M", "L", "XL"

    should_validate_exclusion_of :size, "XS", "XM"
    should_not_validate_exclusion_of :size, "S", "M", "L", "XL"

    should_require_attributes :price, :title
    should_validate_presence_of :price, :title

    should_ensure_value_in_range :price, 1..9999
    should_ensure_value_in_range :weight, 1..100

    should_validate_inclusion_of :price, 1..9999
    should_validate_inclusion_of :price, 1..9999, :allow_nil => true
    should_not_validate_inclusion_of :price, 1..9999, :allow_nil => false

    should_validate_inclusion_of :weight, 1..100
    should_validate_inclusion_of :weight, 1..100, :allow_blank => true
    should_not_validate_inclusion_of :weight, 1..100, :allow_blank => false

    should_ensure_length_in_range :size, 5..20
    should_validate_length_of :size, :in => 5..20, :allow_blank => true
    should_not_validate_length_of :size, :in => 1..10
    should_not_validate_length_of :size, :within =>5..20, :allow_blank => false
  end
end
