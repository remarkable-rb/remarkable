module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Macros
      include Matchers

      def method_missing_with_remarkable(method_id, *args, &block)
        if method_id.to_s =~ /^should_not_(.*)/
          should_not_method_missing($1, *args)
        elsif method_id.to_s =~ /^should_(.*)/
          should_method_missing($1, *args)
        elsif method_id.to_s =~ /^xshould_(not_)?(.*)/
          pending_method_missing($2, $1, *args)
        else
          method_missing_without_remarkable(method_id, *args, &block)
        end
      end
      alias_method_chain :method_missing, :remarkable

      private

      def should_not_method_missing(method, *args)
        matcher = create_and_configure_matcher(method, *args)
        it "should not #{matcher.description}" do
          assert_rejects(matcher.negative.spec(self), subject_class)
        end
      end

      def should_method_missing(method, *args)
        matcher = create_and_configure_matcher(method, *args)
        it "should #{matcher.description}" do
          assert_accepts(matcher.spec(self), subject_class)
        end
      end

      def pending_method_missing(method, negative, *args)
        matcher = create_and_configure_matcher(method, *args)
        matcher.negative if negative
        description = matcher.description
        xit "should #{'not ' if negative}#{description}"
      rescue
        xit "should #{'not ' if negative}#{method.to_s.gsub('_',' ')}"
      end

      def create_and_configure_matcher(method, *args)
        matcher = send(method, *args)
        matcher.table_name = self.described_type.table_name if matcher.respond_to?('table_name=')
        matcher
      end

    end
  end
end
