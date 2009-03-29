module Remarkable
  module Macros
    @@_pending_examples, @@_pending_examples_description = false, nil

    protected

      def pending(description=nil)
        @@_pending_examples, @@_pending_examples_description = true, description
        yield
        @@_pending_examples, @@_pending_examples_description = false, nil
      end

      def method_missing(method_id, *args, &block)
        if method_id.to_s =~ /^(should_not|should)_(.+)/
          if @@_pending_examples
            pending_method_missing(@@_pending_examples_description, $1, $2, caller, *args, &block)
          else
            should_or_should_not_method_missing($1, $2, caller, *args, &block)
          end
        elsif method_id.to_s =~ /^p(should_not|should)_(.+)/
          pending_method_missing(nil, $1, $2, caller, *args, &block)
        elsif method_id.to_s =~ /^x(should_not|should)_(.+)/
          disabled_method_missing($1, $2, *args, &block)
        else
          super(method_id, *args, &block)
        end
      end

      def should_or_should_not_method_missing(should_or_should_not, method, calltrace, *args, &block)
        it {
          begin
            send(should_or_should_not, send(method, *args, &block))
          rescue Exception => e
            e.set_backtrace(calltrace.to_a)
            raise e
          end
        }
      end

      def disabled_method_missing(should_or_should_not, method, *args, &block)
        description = get_description_from_matcher(should_or_should_not, method, *args, &block)
        xexample(description)
      end

      def pending_method_missing(pending_text, should_or_should_not, method, calltrace, *args, &block)
        description   = get_description_from_matcher(should_or_should_not, method, *args, &block)
        method_caller = calltrace.detect{ |c| c !~ /method_missing/ }

        example(description) do
          if ::Spec::Example::ExamplePendingError.method(:new).arity == 2
            raise Spec::Example::ExamplePendingError.new(pending_text || 'TODO', method_caller)
          else # For rspec <= 1.1.12
            raise Spec::Example::ExamplePendingError.new(pending_text || 'TODO')
          end
        end
      end

      # Try to get the description from the matcher. If an error is raised, we
      # deduct the description from the matcher name, but it will be shown in
      # english.
      #
      def get_description_from_matcher(should_or_should_not, method, *args, &block)
        verb = should_or_should_not.to_s.gsub('_', ' ')

        desc = Remarkable::Matchers.send(method, *args, &block).description
        verb = Remarkable.t("remarkable.core.#{should_or_should_not}", :default => verb)
      rescue
        desc = method.to_s.gsub('_', ' ')
      ensure
        verb << ' ' << desc
      end

  end
end
