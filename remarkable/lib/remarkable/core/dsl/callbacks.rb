module Remarkable
  module DSL
    module Callbacks

      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        protected
          # Class method that accepts a block or a symbol which is called after
          # initialization.
          #
          # == Examples
          #
          #   after_initialize :evaluate_given_blocks
          #
          #   after_initialize do
          #     # code
          #   end
          #
          def after_initialize(*symbols, &block)
            if block_given?
              @after_initialize_callbacks << block
            else
              @after_initialize_callbacks += symbols
            end
          end

          # Class method that accepts a block or a symbol which is called before
          # running assertions.
          #
          # == Examples
          #
          #   before_assert :evaluate_given_blocks
          #
          #   before_assert do
          #     # code
          #   end
          #
          def before_assert(*symbols, &block)
            if block_given?
              @before_assert_callbacks << block
            else
              @before_assert_callbacks += symbols
            end
          end
      end

      def run_after_initialize_callbacks #:nodoc:
        self.class.after_initialize_callbacks.each do |method|
          if method.is_a?(Proc)
            instance_eval &method
          elsif method.is_a?(Symbol)
            send(method)
          end
        end
      end

      def run_before_assert_callbacks #:nodoc:
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
