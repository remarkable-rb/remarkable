module Remarkable
  module DSL
    module Optionals

      protected

        # Creates optional handlers for matchers dynamically. The following
        # statement:
        #
        #   optional :range, :default => 0..10
        #
        # Will generate:
        #
        #   def range(value=0..10)
        #     @options ||= {}
        #     @options[:range] = value
        #     self
        #   end
        #
        # Options:
        #
        # * <tt>:default</tt> - The default value for this optional
        # * <tt>:alias</tt>  - An alias for this optional
        #
        # Examples:
        #
        #   optional :name, :title
        #   optional :range, :default => 0..10, :alias => :within
        #
        # Optionals will be included in description messages if you assign them
        # properly on your locale file. If you have a validate_uniqueness_of
        # matcher with the following on your locale file:
        #
        #   description: validate uniqueness of {{attributes}}
        #   optional:
        #     scope:
        #       given: scoped to {{inspect}}
        #     case_sensitive:
        #       positive: case sensitive
        #       negative: case insensitive
        #
        # When invoked like below will generate the following messages:
        #
        #   validate_uniqueness_of :project_id, :scope => :company_id
        #   #=> "validate uniqueness of project_id scoped to company_id"
        #
        #   validate_uniqueness_of :project_id, :scope => :company_id, :case_sensitive => true
        #   #=> "validate uniqueness of project_id scoped to company_id and case sensitive"
        #
        #   validate_uniqueness_of :project_id, :scope => :company_id, :case_sensitive => false
        #   #=> "validate uniqueness of project_id scoped to company_id and case insensitive"
        #
        # The options for each optional are:
        #
        #   * <tt>positive</tt> - When the key is given and it's not false or nil.
        #   * <tt>negative</tt> - When the key is given and it's false or nil.
        #   * <tt>given</tt> - When the key is given, doesn't matter the value.
        #   * <tt>not_given</tt> - When the key is not given.
        #
        def optional(*names)
          options = names.extract_options!
          @matcher_optionals += names

          include Remarkable::DSL::Description unless ancestors.include?(Remarkable::DSL::Description)

          names.each do |name|
            class_eval <<-END, __FILE__, __LINE__
def #{name}(value#{ options[:default] ? "=#{options[:default].inspect}" : "" })
  @options ||= {}
  @options[:#{name}] = value
  self
end
END
          end
          class_eval "alias_method(:#{options[:alias]}, :#{names.last})" if options[:alias]

          # Call unique to avoid duplicate optionals.
          @matcher_optionals.uniq!
        end

    end
  end
end
