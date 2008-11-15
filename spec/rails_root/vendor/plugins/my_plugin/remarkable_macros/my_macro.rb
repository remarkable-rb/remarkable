module Remarkable
  module Syntax

    module RSpec
      def run_my_plugin_macro
        simple_matcher "run my plugin macro" do
          true
        end
      end
    end

    module Shoulda
      def should_run_my_plugin_macro
        it "should run my plugin macro" do
          true.should be_true
        end
      end
    end

  end 
end
