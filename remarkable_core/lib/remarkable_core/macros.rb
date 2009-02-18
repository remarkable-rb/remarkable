module Remarkable # :nodoc:
  module Macros

    def method_missing_with_remarkable(method_id, *args, &block)
      if method_id.to_s =~ /^should_not_(.*)/
        should_not_method_missing($1, *args, &block)
      elsif method_id.to_s =~ /^should_(.*)/
        should_method_missing($1, *args, &block)
      elsif method_id.to_s =~ /^xshould_(not_)?(.*)/
        pending_method_missing($2, $1, *args, &block)
      else
        method_missing_without_remarkable(method_id, *args, &block)
      end
    end

    alias_method :method_missing_without_remarkable, :method_missing
    alias_method :method_missing, :method_missing_with_remarkable

    private

      def should_not_method_missing(method, *args, &block)
        matcher = find_and_configure_matcher(method, *args, &block)
        it { should_not matcher.spec(self) }
      end

      def should_method_missing(method, *args, &block)
        matcher = find_and_configure_matcher(method, *args, &block)
        it { should matcher.spec(self) }
      end

      def pending_method_missing(method, negative, *args, &block)
        matcher = find_and_configure_matcher(method, *args, &block)
        matcher.negative if negative
        description = matcher.description
        xit "should #{'not ' if negative}#{description}"
      rescue
        xit "should #{'not ' if negative}#{method.to_s.gsub('_',' ')}"
      end

      # Overwrite this to extend macros behavior
      def find_and_configure_matcher(method, *args, &block)
        send(method, *args, &block)
      end

  end
end
