module Remarkable
  module DSL
    module Optionals

      OPTIONAL_KEYS = [ :positive, :negative, :not_given ]

      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end

      module ClassMethods

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
          # * <tt>:splat</tt>  - Should be true if you expects multiple arguments
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
          #   optionals:
          #     scope:
          #       positive: scoped to {{value}}
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
          # The interpolation options available are "value" and "inspect". Where
          # the first is the optional value transformed into a string and the
          # second is the inspected value.
          #
          # Three keys are available to be used in I18n files and control how
          # optionals are appended to your description:
          #
          #   * <tt>positive</tt> - When the optional is given and it evaluates to true (everything but false and nil).
          #   * <tt>negative</tt> - When the optional is given and it evaluates to false (false or nil).
          #   * <tt>not_given</tt> - When the optional is not given.
          #
          def optionals(*names)
            options = names.extract_options!
            @matcher_optionals += names

            splat   = options[:splat]   ? '*' : ''
            default = options[:default] ? "=#{options[:default].inspect}" : ""

            names.each do |name|
              class_eval <<-END, __FILE__, __LINE__
                def #{name}(#{splat}value#{default})
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
          alias :optional :optionals

          # Instead of appending, prepend optionals to the beginning of optionals
          # array. This is important because this decide how the description
          # message is generated.
          #
          def prepend_optionals(*names)
            current_optionals  = @matcher_optionals.dup
            @matcher_optionals = []
            optional(*names)
            @matcher_optionals += current_optionals
            @matcher_optionals.uniq!
          end
          alias :prepend_optional :prepend_optionals

      end

      # Overwrites description to support optionals. Check <tt>optional</tt> for
      # more information.
      #
      def description(options={}) #:nodoc:
        message = super(options)
        message.strip!

        optionals = self.class.matcher_optionals.map do |optional|
          if @options.key?(optional)
            value = @options[optional]
            defaults = [ (value ? :positive : :negative) ]

            # If optional is a symbol and it's not any to any of the reserved symbols, search for it also
            defaults.unshift(value) if value.is_a?(Symbol) && !OPTIONAL_KEYS.include?(value)
            defaults << ''

            options = { :default => defaults, :inspect => value.inspect, :value => value.to_s }
            translate_optionals_with_namespace(optional, defaults.shift, options)
          else
            translate_optionals_with_namespace(optional, :not_given, :default => '')
          end
        end.compact

        message << ' ' << array_to_sentence(optionals)
        message.strip!
        message
      end

      def translate_optionals_with_namespace(optional, key, options={}) #:nodoc:
        scope = "#{matcher_i18n_scope}.optionals.#{optional}"

        translation = Remarkable.t key, options.merge!(:scope => scope)
        return translation unless translation.empty?

        parent_scope = scope.split('.')
        parent_scope.delete_at(-3)
        translation = Remarkable.t key, options.merge!(:scope => parent_scope)
        return translation unless translation.empty?

        nil
      end

    end
  end
end
