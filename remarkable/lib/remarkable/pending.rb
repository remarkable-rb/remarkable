module Remarkable
  module Macros

    protected

      # Adds a pending block to your specs.
      #
      # == Examples
      #
      #   pending 'create manager resource' do
      #     should_have_one :manager
      #     should_validate_associated :manager
      #   end
      #
      def pending(description='TODO', &block)
        PendingSandbox.new(description, self).instance_eval(&block)
      end

      class PendingSandbox < Struct.new(:description, :spec) #:nodoc:
        include Macros

        def example(mather_description=nil)
          method_caller = caller.detect{ |c| c !~ /method_missing'/ }

          error = begin
            ::Spec::Example::ExamplePendingError.new(description, method_caller)
          rescue # For rspec <= 1.1.12 and rspec => 1.2.4
            ::Spec::Example::ExamplePendingError.new(description)
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
