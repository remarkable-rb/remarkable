module Remarkable
  module Macros

    def method_missing(method_id, *args, &block)
      if method_id.to_s =~ /^(should_not|should)_(.+)/
        should_or_should_not_method_missing($1, $2, caller, *args, &block)
      elsif method_id.to_s =~ /^xshould_(not_)?(.+)/
        pending_method_missing($1, $2, *args, &block)
      else
        super(method_id, *args, &block)
      end
    end

    private

      def should_or_should_not_method_missing(should_or_should_not, method, calltrace, *args, &block)
        it do
          begin
            send(should_or_should_not, send(method, *args, &block))
          rescue Exception => e
            backtrace = e.backtrace.to_a + calltrace.to_a
            backtrace.uniq!
            e.set_backtrace(backtrace)
            raise e
          end
        end
      end

      def pending_method_missing(negative, method, *args, &block)
        # Create an example group instance and get the matcher.
        matcher = self.new('pending_method_missing_group').send(method, *args, &block)
        description = matcher.description

        verb = Remarkable.t(negative ? 'remarkable.core.should_not' : 'remarkable.core.should')
        xit "#{verb} #{description}"
      rescue
        xit "should #{'not ' if negative}#{method.to_s.gsub('_',' ')}"
      end

  end
end
