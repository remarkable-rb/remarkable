module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Macros
      include Matchers

      # Ensures that there are DB indices on the given columns or tuples of columns.
      # Also aliased to should_have_index for readability
      #
      #   should_have_indices :email, :name, [:commentable_type, :commentable_id]
      #   should_have_index :age
      #
      def should_have_indices(*columns)
        columns.each do |column|
          matcher = have_index(column)
          it "should have index on #{self.described_type.table_name} for #{column.inspect}" do
            assert_accepts(matcher, model_class)
          end
        end
      end
      alias_method :should_have_index, :should_have_indices

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
        it "should not #{matcher.description}" do
          assert_rejects(matcher, model_class)
        end
      end

      def should_method_missing(method, *args)
        matcher = send(method, *args)
        it "should #{matcher.description}" do
          assert_accepts(matcher, model_class)
        end
      end
      
    end
  end
end
