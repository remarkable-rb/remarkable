module Remarkable
  module Controller
    module Syntax

      module RSpec
        # Macro that creates a test asserting that a value returned from the session is correct.
        # The given string is evaled to produce the resulting redirect path.  All of the instance variables
        # set by the controller are available to the evaled string.
        # Example:
        #
        #   it { should return_from_session(:user_id, '@user.id') }
        #   it { should return_from_session(:message, '"Free stuff"') }
        # 
        def return_from_session(key, expected)
          simple_matcher "return the correct value from the session for key #{key}" do
            ret = true
            instantiate_variables_from_assigns do
              expected_value = eval(expected, self.send(:binding), __FILE__, __LINE__)
              ret = (session[key] == expected_value)
            end
            ret
          end
        end
      end

      module Shoulda
        # Macro that creates a test asserting that a value returned from the session is correct.
        # The given string is evaled to produce the resulting redirect path.  All of the instance variables
        # set by the controller are available to the evaled string.
        # Example:
        #
        #   should_return_from_session :user_id, '@user.id'
        #   should_return_from_session :message, '"Free stuff"'
        # 
        def should_return_from_session(key, expected)
          it "should return the correct value from the session for key #{key}" do
            instantiate_variables_from_assigns do
              expected_value = eval(expected, self.send(:binding), __FILE__, __LINE__)
              session[key].should == expected_value
            end
          end
        end
      end

    end
  end
end
