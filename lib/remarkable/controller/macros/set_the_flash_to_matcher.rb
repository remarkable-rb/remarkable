module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class SetTheFlashTo < Remarkable::Matcher::Base
        include Remarkable::Controller::Helpers
        
        def initialize(val)
          @val = val
        end

        def matches?(subject)
          @subject = subject
          assert_matcher do
            flash_correct?
          end
        end

        def description
          expectation
        end
        
        private
        
        def flash_correct?
          if @val
            return true if assert_contains(@flash.values, @val)
            @missing = "not have #{@val} in the flash"
          else
            return true if @flash == {}
            @missing = "flash is not empty"
          end
          return false
        end
        
        def expectation
          if @val
            "have #{@val.inspect} in the flash"
          else
            "set the flash"
          end
        end
      end

      def set_the_flash_to(val = '')
        SetTheFlashTo.new(val)
      end
      alias_method :set_the_flash, :set_the_flash_to
    end
  end
end
