module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Helpers # :nodoc:
      include Remarkable::Default::Helpers
      
      private # :enddoc:

      SPECIAL_INSTANCE_VARIABLES = %w{
        _cookies
        _flash
        _headers
        _params
        _request
        _response
        _session
        action_name
        before_filter_chain_aborted
        cookies
        flash
        headers
        ignore_missing_templates
        logger
        params
        request
        request_origin
        response
        session
        template
        template_class
        template_root
        url
        variables_added
        }.map(&:to_s)

      def instantiate_variables_from_assigns(*names, &blk) # :nodoc:
        old = {}
        names = (@response.template.assigns.keys - SPECIAL_INSTANCE_VARIABLES) if names.empty?
        names.each do |name|
          old[name] = instance_variable_get("@#{name}")
          instance_variable_set("@#{name}", controller_assigns(name.to_sym))
        end
        blk.call
        names.each do |name|
          instance_variable_set("@#{name}", old[name])
        end
      end
      
      def controller_assigns(key)
        @controller.instance_variable_get("@#{key}")
      end
      
    end
  end
end
