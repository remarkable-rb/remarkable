module Remarkable
  module DSL
    module Callbacks

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        protected
          # Class method that accepts a block or a symbol which is called after initialization.
          #
          def after_initialize(symbol=nil, &block)
            if block_given?
              @after_initialize_callbacks << block
            elsif symbol
              @after_initialize_callbacks << symbol
            end
          end

          # Class method that accepts a block or a symbol which is called before assertion.
          #
          def before_assert(symbol=nil, &block)
            if block_given?
              @before_assert_callbacks << block
            elsif symbol
              @before_assert_callbacks << symbol
            end
          end
      end

      def run_after_initialize_callbacks
        self.class.after_initialize_callbacks.each do |method|
          if method.is_a?(Proc)
            instance_eval &method
          elsif method.is_a?(Symbol)
            send(method)
          end
        end
      end

      def run_before_assert_callbacks
        self.class.before_assert_callbacks.each do |method|
          if method.is_a?(Proc)
            instance_eval &method
          elsif method.is_a?(Symbol)
            send(method)
          end
        end
      end

    end
  end
end
