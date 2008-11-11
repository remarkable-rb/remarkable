module Spec
  module Example
    module ExampleMethods
      def should(matcher)
        case matcher.class.name
        when "Spec::Rails::Matchers::RenderTemplate", "Spec::Rails::Matchers::RedirectTo"
          remarkable_response.should matcher
        else
          remarkable_subject.should matcher
        end
      end

      def should_not(matcher)
        case matcher.class.name
        when "Spec::Rails::Matchers::RenderTemplate", "Spec::Rails::Matchers::RedirectTo"
          remarkable_response.should_not matcher
        else
          remarkable_subject.should_not matcher
        end
      end

      def remarkable_subject
        @remarkable_subject = subject if self.respond_to?(:subject)
        @remarkable_subject ||= self.class.described_type
      end

      def remarkable_response
        @remarkable_response ||= self.response if self.respond_to?(:response)        
      end
    end
  end
end
