module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Helpers # :nodoc:
      include Remarkable::Default::Helpers
      
      private # :enddoc:

      def controller_assigns(key)
        @controller.instance_variable_get("@#{key}")
      end
      
    end
  end
end
