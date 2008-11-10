module Spec
  module Example
    module ExampleMethods
      def should(matcher)
        remarkable_subject.should(matcher)
      end

      def should_not(matcher)
        remarkable_subject.should_not(matcher)
      end

      def remarkable_subject
        @remarkable_subject = subject if self.respond_to?(:subject)
        @remarkable_subject ||= self.class.described_type
      end
    end
  end
end
