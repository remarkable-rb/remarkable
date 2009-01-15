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
          @method = method
        end

        def matches?(subject)
          @subject = subject
        
          assert_matcher_for(@callback) do |column|
            callbacks_for(@callback).include?(@method)
          end
        end

        def failure_message
          "Expected #{expectation}"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          "have a #{@callback} callback named #{@method}"
        end

        protected

        def expectation
          "#{model_name} to #{description}"
        end
        
        def callbacks_for(callback)
          model_class.send("#{callback}_callback_chain").collect(&:method)
        end
      end
    end
  end
end
