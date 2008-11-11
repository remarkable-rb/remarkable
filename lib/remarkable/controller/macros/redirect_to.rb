module Spec
  module Rails
    module Matchers

      # Macro that creates a test asserting that the controller returned a redirect to the given path.
      # The given string is evaled to produce the resulting redirect path.  All of the instance variables
      # set by the controller are available to the evaled string.
      # Example:
      #
      #   should_redirect_to '"/"'
      #   should_redirect_to "user_url(@user)"
      #   should_redirect_to "users_url"
      # 
      alias_method :redirect_to_without_eval, :redirect_to
      def redirect_to_with_eval(url)
        simple_matcher "should redirect to #{url.inspect}" do
          instantiate_variables_from_assigns do
            response.should redirect_to_without_eval(eval(url, self.send(:binding), __FILE__, __LINE__))
          end
        end
      end
      
      # alias_method :foo?, :foo_with_feature?
      
      # alias_method_chain :redirect_to, :eval

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