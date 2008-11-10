module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Helpers # :nodoc:
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

      def instantiate_variables_from_assigns(*names, &blk)
        old = {}
        names = (response.template.assigns.keys - SPECIAL_INSTANCE_VARIABLES) if names.empty?
        names.each do |name|
          old[name] = instance_variable_get("@#{name}")
          instance_variable_set("@#{name}", assigns(name.to_sym))
        end
        blk.call
        names.each do |name|
          instance_variable_set("@#{name}", old[name])
        end
      end
      
      # Asserts that the given collection contains item x.  If x is a regular expression, ensure that
      # at least one element from the collection matches x.
      #
      #   assert_contains(['a', '1'], /\d/) => passes
      #   assert_contains(['a', '1'], 'a') => passes
      #   assert_contains(['a', '1'], /not there/) => fails
      # 
      def assert_contains(collection, x)
        collection = [collection] unless collection.is_a?(Array)
        case x
        when Regexp
          collection.detect { |e| e =~ x }.should_not be_nil
        else
          collection.include?(x).should_not be_nil
        end
      end
      
    end
  end
end
