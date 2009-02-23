module Remarkable
  module ActionController
    module Matchers
      class RedirectToMatcher < Remarkable::ActionController::Base #:nodoc:
        arguments :expected, :block => :block

        before_assert do
          super
          @expected = @spec.instance_eval(&@block) if @block

          if @subject.is_a?(::ActionController::TestResponse)
            @response   = @subject
            @controller = @spec.instance_variable_get('@controller')
          else
            @controller = @subject
            @response   = @spec.instance_variable_get('@response')
          end

          @request = @spec.instance_variable_get('@request')
        end

        single_assertions :redirected?, :url_match?

        protected

          def redirected?
            @response.redirect?
          end

          def url_match?
            @actual = @response.redirect_url

            if @expected.is_a? Hash
              return false unless @actual =~ /^\w+:\/\/#{@request.host}/
              return false unless actual_redirect_to_valid_route
              return true  if actual_hash == expected_hash
            else
              return true  if @actual == expected_url
            end

            return false, :actual => @actual.inspect
          end

          def actual_hash
            hash_from_url @actual
          end

          def expected_hash
            hash_from_url expected_url
          end

          def actual_redirect_to_valid_route
            actual_hash
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
            QueryParameterParser.parse_query_parameters(query, @request)
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

          class QueryParameterParser
            def self.parse_query_parameters(query, request)
              if defined?(CGIMethods)
                CGIMethods.parse_query_parameters(query)
              elsif defined?(ActionController::RequestParser)
                ActionController::RequestParser.parse_query_parameters(query)
              else
                request.class.parse_query_parameters(query)
              end
            end
          end
      end

      # Passes if the response is a redirect to the url, action or controller/action.
      # Useful in controller specs (integration or isolation mode).
      #
      # == Examples
      #
      #   should_redirect_to { users_url(mock_user) }
      #   should_redirect_to { users_url(users(:first)) }
      #
      #   it { should redirect_to("path/to/action") }
      #   it { should redirect_to("http://test.host/path/to/action") }
      #   it { should redirect_to(:action => 'list') }
      #
      def redirect_to(expected=nil, &block)
        RedirectToMatcher.new(expected, &block).spec(self)
      end

    end
  end
end
