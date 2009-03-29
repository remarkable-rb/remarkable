module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class SetTheFlash < Remarkable::Matcher::Base
        include Remarkable::Controller::Helpers
        
        def initialize(val)
          @val = if val.is_a?(Hash)
            val[:to]
          else
            nil
          end
        end

        def to(val)
          @val = val
          self
        end

        def matches?(subject)
          initialize_with_spec!

          @subject = subject
          assert_matcher do
            flash_correct?
          end
        end

        def description
          expectation
        end

        private

        def initialize_with_spec!
          # In Rspec 1.1.12 we can actually do:
          #
          #   @flash = @subject.flash
          #
          @flash = @spec.instance_eval { flash }
        end

        def flash_correct?
          if @val
            return true if assert_contains(@flash.values, @val)
            @missing = "not have #{@val} in the flash"
          else
            return true if @flash.blank?
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

      def set_the_flash(val={:to=>''})
        SetTheFlash.new(val)
      end
    end
  end
end
