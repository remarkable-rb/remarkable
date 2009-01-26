module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Macros
      include Matchers

      def method_missing_with_remarkable(method_id, *args, &block)
        if method_id.to_s =~ /^should_not_(.*)/
          should_not_method_missing($1.to_sym, *args)
        elsif method_id.to_s =~ /^should_(.*)/
          should_method_missing($1.to_sym, *args)
        else
          method_missing_without_remarkable(method_id, *args, &block)
        end
      end
      alias_method_chain :method_missing, :remarkable

      private

      def should_not_method_missing(method, *args)
        matcher = send(method, *args).negative
        matcher.table_name = self.described_type.table_name if matcher.respond_to?('table_name=')
        it "should not #{matcher.description}" do
          assert_rejects(matcher, model_class)
        end
      end

      def should_method_missing(method, *args)
        matcher = send(method, *args)
        matcher.table_name = self.described_type.table_name if matcher.respond_to?('table_name=')
        it "should #{matcher.description}" do
          assert_accepts(matcher, model_class)
        end
      end
      
    end
  end
end
