module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Macros # :nodoc:
      include Matchers

      def should_render_template(template)
        it "should render template #{template.inspect}" do
          response.should render_template(template.to_s)
        end
      end

      def should_not_render_template(template)
        it "should render template #{template.inspect}" do
          response.should_not render_template(template.to_s)
        end
      end

      def should_redirect_to(url)
        it "should redirect to #{url.inspect}" do
          instantiate_variables_from_assigns do
            warn_level = $VERBOSE
            $VERBOSE = nil
            response.should redirect_to(eval(url, self.send(:binding), __FILE__, __LINE__))
            $VERBOSE = warn_level
          end
        end
      end
      
      def should_not_redirect_to(url)
        it "should not redirect to #{url.inspect}" do
          instantiate_variables_from_assigns do
            warn_level = $VERBOSE
            $VERBOSE = nil
            response.should_not redirect_to(eval(url, self.send(:binding), __FILE__, __LINE__))
            $VERBOSE = warn_level
          end
        end
      end

      def should_not_set_the_flash
        should_method_missing :set_the_flash_to, nil
      end

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

      def should_method_missing(method, *args)
        matcher = send(method, *args)
        it "should #{matcher.description}" do
          matcher.controller(controller).response(response).session(session).flash(flash).spec(self)
          assert_accepts(matcher, model_class)
        end
      end

      def should_not_method_missing(method, *args)
        matcher = send(method, *args)
        it "should not #{matcher.description}" do
          matcher.controller(controller).response(response).session(session).flash(flash).spec(self).negative
          assert_rejects(matcher, model_class)
        end
      end
    end
  end
end
