module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Macros
      include Matchers

      def method_missing_with_remarkable(method_id, *args, &block)
        if method_id =~ /^should_not_/
          matcher = self.send(method_id, *args).negative
          it "should not #{matcher.description}" do
            assert_rejects(matcher, model_class)
          end
        elsif method_id =~ /^should_/
          matcher = self.send(method_id, *args)
          it "should #{matcher.description}" do
            assert_accepts(matcher, model_class)
          end
        else
          method_missing_without_remarkable(method_id, *args, &block)
        end
      end

      alias_method_chain :method_missing, :remarkable
    end
  end
end
