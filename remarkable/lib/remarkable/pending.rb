module Remarkable
  module Macros

    protected

      def pending(description=nil, &block)
        PendingSandbox.new(description, self).instance_eval(&block)
      end

      class PendingSandbox < Struct.new(:description, :spec) #:nodoc:
        include Macros

        def example(mather_description=nil)
          method_caller = caller.detect{ |c| c !~ /method_missing'/ }

          error = begin
            ::Spec::Example::ExamplePendingError.new(description || 'TODO', method_caller)
          rescue # For rspec <= 1.1.12
            ::Spec::Example::ExamplePendingError.new(description || 'TODO')
          end

          spec.send(:example, mather_description){ raise error }
        end
        alias :it      :example
        alias :specify :example

        def should_or_should_not_method_missing(should_or_should_not, method, calltrace, *args, &block)
          example(get_description_from_matcher(should_or_should_not, method, *args, &block))
        end
      end

  end
end
