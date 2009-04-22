require File.join(File.dirname(__FILE__), 'set_session_matcher')

module Remarkable
  module ActionController
    module Matchers
      class SetCookiesMatcher < SetSessionMatcher #:nodoc:

        # For cookies to work properly, we have:
        #
        # On Rails 2.1.2 and 2.2.2:
        #
        #   1. Wrap :to values in an array;
        #   2. When :to is false or nil, make it be an empty array;
        #   3. Convert all keys to string.
        #
        # On Rails 2.3.2:
        #
        #   1. Return nil if nil, join when array or convert to string;
        #   2. Convert all keys to string.
        #
        before_assert do
          if @options.key?(:to)
            if @subject.request.env.key?("rack.input")
              @options[:to] = case @options[:to]
                when nil
                  nil
                when Array
                  @options[:to].join('&')
                else
                  @options[:to].to_s
              end
            else
              @options[:to] = @options[:to] ? Array(@options[:to]) : []
            end
          end

          @keys.collect!(&:to_s)
        end

        protected
          def session
            @subject ? (@subject.response.cookies || {}) : {}
          end

          def interpolation_options
            { :cookies_inspect => session.symbolize_keys!.inspect }
          end

      end

      # Ensures that the given cookie keys were set. If you want to check that
      # a cookie is not being set, just do:
      #
      #   should_not_set_cookies :user
      #
      # If you want to assure that a cookie is being set to nil, do instead:
      #
      #   should_set_cookies :user, :to => nil
      #
      # Note: this method is also aliased as <tt>set_cookie</tt>.
      #
      # == Options
      #
      # * <tt>:to</tt> - The value to compare the session key.
      #   It accepts procs and be also given as a block (see examples below).
      #
      # == Examples
      #
      #   should_set_cookies :user_id, :user
      #   should_set_cookies :user_id, :to => 2
      #   should_set_cookies :user, :to => proc{ users(:first) }
      #   should_set_cookies(:user){ users(:first) }
      #
      #   it { should set_cookies(:user_id, :user) }
      #   it { should set_cookies(:user_id, :to => 2) }
      #   it { should set_cookies(:user, :to => users(:first)) }
      #
      def set_cookies(*args, &block)
        SetCookiesMatcher.new(*args, &block).spec(self)
      end
      alias :set_cookie :set_cookies

    end
  end
end
