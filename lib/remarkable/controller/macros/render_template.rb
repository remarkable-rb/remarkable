module Remarkable
  module Controller
    module Syntax

      module Shoulda
        # Macro that creates a test asserting that the controller rendered the given template.
        # Example:
        #
        #   should_render_template :new
        # 
        def should_render_template(template)
          it "should render template #{template.inspect}" do
            response.should render_template(template.to_s)
          end
        end
      end

    end
  end
end
