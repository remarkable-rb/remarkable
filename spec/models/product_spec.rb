require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Product do
  describe "An intangible product" do
    before(:all) do
      @product = Product.new(:tangible => false)
    end
    
    it { @product.should_not allow_values_for(:size, "22") }
    it { @product.should allow_values_for(:size, "22kb") }
  end
  
  describe "A tangible product" do
    before(:all) do
      @product = Product.new(:tangible => true)
    end
    
    it { @product.should_not allow_values_for(:size, "22", "10x15") }
    it { @product.should allow_values_for(:size, "12x12x1") }
  end

  # context "An intangible product" do
  #   setup do
  #     @product = Product.new(:tangible => false)
  #   end
  # 
  #   should_require_attributes :title
  #   should_ensure_value_in_range :price, 0..99
  # end
  # 
  # context "A tangible product" do
  #   setup do
  #     @product = Product.new(:tangible => true)
  #   end
  # 
  #   should_require_attributes :price
  #   should_ensure_value_in_range :price, 1..9999
  #   should_ensure_value_in_range :weight, 1..100
  #   should_ensure_length_in_range :size, 5..20
  # end
end
