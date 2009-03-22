module Remarkable
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

      def should_method_missing(method, *args, &block)
        it { should send(method, *args, &block) }
      end

      def should_not_method_missing(method, *args, &block)
        it { should_not send(method, *args, &block) }
      end

      def pending_method_missing(method, negative, *args, &block)
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
