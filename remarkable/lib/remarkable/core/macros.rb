module Remarkable
  # This class is responsable for converting matchers to macros. You shouldn't
  # worry with what happens here, because it happens automatically.
  #
  module Macros

    protected

      def method_missing(method_id, *args, &block) #:nodoc:
        if method_id.to_s =~ /^(should_not|should)_(.+)/
          should_or_should_not_method_missing($1, $2, caller, *args, &block)
        elsif method_id.to_s =~ /^x(should_not|should)_(.+)/
          disabled_method_missing($1, $2, *args, &block)
        else
          super(method_id, *args, &block)
        end
      end

      def should_or_should_not_method_missing(should_or_should_not, method, calltrace, *args, &block) #:nodoc:
        description = if @_pending_group
          get_description_from_matcher(should_or_should_not, method, *args, &block)
        else
          nil
        end

        example(description){
          begin
            send(should_or_should_not, send(method, *args, &block))
          rescue Exception => e
            trace = e.backtrace.to_a + calltrace.to_a
            e.set_backtrace(trace)
            raise e
          end
        }
      end

      def disabled_method_missing(should_or_should_not, method, *args, &block) #:nodoc:
        description = get_description_from_matcher(should_or_should_not, method, *args, &block)
        xexample(description)
      end

      # Try to get the description from the matcher. If an error is raised, we
      # deduct the description from the matcher name, but it will be shown in
      # english.
      #
      def get_description_from_matcher(should_or_should_not, method, *args, &block) #:nodoc:
        verb = should_or_should_not.to_s.gsub('_', ' ')

        desc = Remarkable::Matchers.send(method, *args, &block).spec(self).description
        verb = Remarkable.t("remarkable.core.#{should_or_should_not}", :default => verb)
      rescue
        desc = method.to_s.gsub('_', ' ')
      ensure
        verb << ' ' << desc
      end

  end
end
