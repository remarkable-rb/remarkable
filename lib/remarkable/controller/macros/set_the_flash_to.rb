module Remarkable
  module Syntax

    module RSpec
      # Macro that creates a test asserting that the flash contains the given value.
      # val can be a String, a Regex, or nil (indicating that the flash should not be set)
      #
      # Example:
      #
      #   should_set_the_flash_to "Thank you for placing this order."
      #   should_set_the_flash_to /created/i
      #   should_set_the_flash_to nil
      # 
      def set_the_flash_to(val = nil)
        if val
          simple_matcher "should have #{val.inspect} in the flash" do
            assert_contains(flash.values, val)
          end
        else
          simple_matcher "should not set the flash" do
            assert_equal({}, flash)
          end
        end
      end
      alias_method :set_the_flash, :set_the_flash_to
    end

    module Shoulda
      # Macro that creates a test asserting that the flash contains the given value.
      # val can be a String, a Regex, or nil (indicating that the flash should not be set)
      #
      # Example:
      #
      #   should_set_the_flash_to "Thank you for placing this order."
      #   should_set_the_flash_to /created/i
      #   should_set_the_flash_to nil
      # 
      def should_set_the_flash_to(val)
        if val
          it "should have #{val.inspect} in the flash" do
            assert_contains(flash.values, val)
          end
        else
          it "should not set the flash" do
            assert_equal({}, flash)
          end
        end
      end

      # Macro that creates a test asserting that the flash is empty.  Same as
      # @should_set_the_flash_to nil@
      def should_not_set_the_flash
        should_set_the_flash_to nil
      end
    end

  end
end
