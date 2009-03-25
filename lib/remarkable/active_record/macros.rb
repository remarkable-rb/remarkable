module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Macros
      include Matchers

      def method_missing_with_remarkable(method_id, *args, &block)
        if method_id.to_s =~ /^should_not_(.*)/
          should_not_method_missing($1, caller, *args, &block)
        elsif method_id.to_s =~ /^should_(.*)/
          should_method_missing($1, caller, *args, &block)
        elsif method_id.to_s =~ /^xshould_(not_)?(.*)/
          pending_method_missing($2, $1, *args, &block)
        else
          method_missing_without_remarkable(method_id, *args, &block)
        end
      end
      alias_method_chain :method_missing, :remarkable

      private

      def should_not_method_missing(method, caller, *args, &block)
        matcher = create_and_configure_matcher(method, *args, &block)
        it "should not #{matcher.description}" do
          begin
            should_not matcher.negative.spec(self)
          rescue Exception => e
            e.set_backtrace(caller.to_a)
            raise e
          end
        end
      end

      def should_method_missing(method, caller, *args, &block)
        matcher = create_and_configure_matcher(method, *args, &block)
        it "should #{matcher.description}" do
          begin
            should matcher.spec(self)
          rescue Exception => e
            e.set_backtrace(caller.to_a)
            raise e
          end
        end
      end

      def pending_method_missing(method, negative, *args, &block)
        matcher = create_and_configure_matcher(method, *args, &block)
        matcher.negative if negative
        description = matcher.description
        xit "should #{'not ' if negative}#{description}"
      rescue
        xit "should #{'not ' if negative}#{method.to_s.gsub('_',' ')}"
      end

      def create_and_configure_matcher(method, *args, &block)
        matcher = send(method, *args, &block)
        matcher.table_name = self.described_type.table_name if matcher.respond_to?('table_name=')
        matcher
      end

    end
  end
end
