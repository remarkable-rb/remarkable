module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Helpers # :nodoc:
      private # :enddoc:

      def model_class
        self.described_type
      end
      
      def fail_with(message)
        Spec::Expectations.fail_with(message)
      end

    end
  end
end
