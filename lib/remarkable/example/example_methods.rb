module Spec
  module Example
    module ExampleMethods
      def should(matcher)
        if rspec_matcher?(matcher)
          remarkable_response.should matcher
        elsif remarkable_matcher?(matcher)
          remarkable_subject.should matcher
        else
          super
        end
      end

      def should_not(matcher)
        if rspec_matcher?(matcher)
          remarkable_response.should_not matcher
        elsif remarkable_matcher?(matcher)
          remarkable_subject.should_not matcher.negative
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

      private

      def rspec_matcher?(matcher)
        %w( Spec::Rails::Matchers::RenderTemplate Spec::Rails::Matchers::RedirectTo ).include?(matcher.class.name)
      end

      def remarkable_matcher?(matcher)
        matcher.class.name =~ /^Remarkable::.+::Matchers::.+$/
      end
    end
  end
end
