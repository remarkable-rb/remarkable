module Remarkable
  module Controller
    module Syntax

      module Shoulda
        # Macro that creates a test asserting that the controller returned a redirect to the given path.
        # The given string is evaled to produce the resulting redirect path.  All of the instance variables
        # set by the controller are available to the evaled string.
        # Example:
        #
        #   should_redirect_to '"/"'
        #   should_redirect_to "user_url(@user)"
        #   should_redirect_to "users_url"
        # 
        def should_redirect_to(url)
          it "should redirect to #{url.inspect}" do
            instantiate_variables_from_assigns do
              response.should redirect_to(eval(url, self.send(:binding), __FILE__, __LINE__))
            end
          end
        end
      end

    end
  end
end
