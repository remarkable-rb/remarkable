module Spec
  module Example
    module ExampleMethods
      def should(matcher)
        subject.should(matcher)
      end

      def should_not(matcher)
        subject.should_not(matcher)
      end

      def subject
        @subject ||= self.class.described_type
      end
    end
  end
end
