module Remarkable
  module ActionController
    module Matchers
      class RedirectToMatcher < Remarkable::ActionController::Base #:nodoc:
        include ::ActionController::StatusCodes

        arguments :expected, :block => true
        optional :with, :block => true

        assertions :redirected?, :status_matches?, :url_matches?

        before_assert :evaluate_expected_value

        before_assert do
          @response = @subject.respond_to?(:response) ? @subject.response : @subject
          @request  = @response.instance_variable_get('@request')
        end

        protected

          def redirected?
            @response.redirect?
          end

          def status_matches?
            return true unless @options.key?(:with)

            actual_status   = interpret_status(@response.response_code)
            expected_status = interpret_status(@options[:with])

            return actual_status == expected_status, :status => @response.response_code.inspect
          end

          def url_matches?
            @actual = @response.redirect_url

            if @expected.instance_of?(Hash)
              return false unless @actual =~ /^\w+:\/\/#{@request.host}/ && actual_hash
              actual_hash == expected_hash
            else
              @actual == expected_url
            end
          end

          def actual_hash
            hash_from_url @actual
          end

          def expected_hash
            hash_from_url expected_url
          end

          def hash_from_url(url)
            query_hash(url).merge(path_hash(url)).with_indifferent_access
          end

          def path_hash(url)
            path = url.sub(/^\w+:\/\/#{@request.host}(?::\d+)?/, "").split("?", 2)[0]
            ::ActionController::Routing::Routes.recognize_path path, { :method => :get }
          end

          def query_hash(url)
            query = url.split("?", 2)[1] || ""

            if defined?(::Rack::Utils)
              ::Rack::Utils.parse_query(query)
            else
              @request.class.parse_query_parameters(query)
            end
          end

          def expected_url
            case @expected
              when Hash
                return ::ActionController::UrlRewriter.new(@request, {}).rewrite(@expected)
              when :back
                return @request.env['HTTP_REFERER']
              when %r{^\w+://.*}
                return @expected
              else
                return "http://#{@request.host}" + (@expected.split('')[0] == '/' ? '' : '/') + @expected
            end
          end

          def interpolation_options
            { :expected => @expected.inspect, :actual => @actual.inspect }
          end

          def evaluate_expected_value
            @expected ||= @block if @block
            @expected = @spec.instance_eval(&@expected) if @expected.is_a?(Proc)
          end

      end

      # Passes if the response redirects to the given url. The url can be a string,
      # a hash or can be supplied as a block (see examples below).
      #
      # == Options
      #
      # * <tt>:with</tt> - The status 30X used when redirecting.
      #
      # == Examples
      #
      #   should_redirect_to{ users_url }
      #   should_redirect_to(:action => 'index')
      #   should_not_redirect_to(:controller => 'users', :action => 'new')
      #
      #   it { should redirect_to(users_url).with(302) }
      #   it { should redirect_to(:action => 'index') }
      #   it { should_not redirect_to(:controller => 'users', :action => 'new') }
      #
      def redirect_to(expected=nil, options={}, &block)
        RedirectToMatcher.new(expected, options, &block).spec(self)
      end

    end
  end
end
