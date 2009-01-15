module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      ::ActiveRecord::Callbacks::CALLBACKS.each do |callback|
        define_method("have_#{callback}_callback") do |method|
          CallbackMatcher.new(callback, method)
        end
      end

      class CallbackMatcher < Remarkable::Matcher::Base
        def initialize(callback, method)
          @callback = callback
          @method   = method
        end

        def matches?(subject)
          @subject = subject
          assert_matcher { has_callback? }
        end

        def description
          "have a #{@callback} callback named #{@method}"
        end

        private

        def has_callback?
          return true if callbacks_for(@callback).include?(@method)

          @missing = "#{model_name} does not have a #{@callback} callback named #{@method}"
          return false
        end

        def callbacks_for(callback)
          model_class.send("#{callback}_callback_chain").collect(&:method)
        end

        def expectation
          "#{model_name} have a #{@callback} callback named #{@method}"
        end

      end
    end
  end
end
