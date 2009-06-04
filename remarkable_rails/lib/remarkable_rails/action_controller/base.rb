module Remarkable
  module ActionController
    class Base < Remarkable::Base

      before_assert :perform_action_with_macro_stubs

      optional :with_expectations, :default => true
      optional :with_stubs,        :default => true

      protected

        # Before assertions, call run_action! to perform the action if it was
        # not performed yet.
        #
        def perform_action_with_macro_stubs #:nodoc:
          @spec.send(:run_action!, run_with_expectations?) if @spec.send(:controller)
        end

        def run_with_expectations? #:nodoc:
          if @options.key?(:with_stubs)
            !@options[:with_stubs]
          elsif @options.key?(:with_expectations)
            @options[:with_expectations]
          else
            true
          end
        end

    end
  end
end
