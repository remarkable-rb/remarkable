module Remarkable
  module Syntax

    module RSpec
      def run_my_custom_macro
        simple_matcher "run my custom macro" do
          true
        end
      end
    end

    module Shoulda
      def should_run_my_custom_macro
        it "should run my custom macro" do
          true.should be_true
        end
      end
    end

  end 
end
