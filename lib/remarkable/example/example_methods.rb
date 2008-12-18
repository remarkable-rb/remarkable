module Spec
  module Example
    module ExampleMethods
      def should(matcher)
        if rspec_matcher?(matcher)
          remarkable_response.should matcher
        elsif remarkable_active_record_matcher?(matcher)
          remarkable_subject.should matcher
        elsif remarkable_controller_matcher?(matcher)
          remarkable_subject.should matcher.controller(remarkable_controller).
                                            response(remarkable_response).
                                            session(session).
                                            flash(flash).
                                            spec(self)
        else
          super
        end
      end

      def should_not(matcher)
        if rspec_matcher?(matcher)
          remarkable_response.should_not matcher
        elsif remarkable_active_record_matcher?(matcher)
          remarkable_subject.should_not matcher.negative
        elsif remarkable_controller_matcher?(matcher)
          remarkable_subject.should_not matcher.controller(remarkable_controller).
                                                response(remarkable_response).
                                                spec(self).
                                                session(session).
                                                flash(flash).
                                                negative
        else
          super
        end
      end

      def remarkable_subject
        @remarkable_subject = subject if self.respond_to?(:subject)
        @remarkable_subject ||= self.class.described_type
      end

      def remarkable_response
        @remarkable_response ||= self.response if self.respond_to?(:response)
      end
      
      def remarkable_controller
        @remarkable_controller ||= self.controller if self.respond_to?(:controller)
      end

      private

      def rspec_matcher?(matcher)
        %w( Spec::Rails::Matchers::RenderTemplate Spec::Rails::Matchers::RedirectTo ).include?(matcher.class.name)
      end

      def remarkable_active_record_matcher?(matcher)
        matcher.class.name =~ /^Remarkable::ActiveRecord::Matchers::.+$/
      end
      
      def remarkable_controller_matcher?(matcher)
        matcher.class.name =~ /^Remarkable::Controller::Matchers::.+$/
      end
    end
  end
end
