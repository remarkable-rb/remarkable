module Remarkable
  module DSL
    module Description

      # Overwrites description to support optionals. Check <tt>optional</tt> for
      # more information.
      #
      def description(options={})
        message = super(options)

        optionals = self.class.matcher_optionals.map do |optional|
          scope = matcher_i18n_scope + ".optional.#{optional}"

          if @options.key?(optional)
            i18n_key = @options[optional] ? :positive : :negative
            Remarkable.t i18n_key, :default => :given, :raise => true, :scope => scope, :inspect => @options[optional].inspect
          else
            Remarkable.t :not_given, :raise => true, :scope => scope
          end rescue nil
        end.compact

        if optionals.empty?
          message
        else
          message + " " + array_to_sentence(optionals)
        end
      end

    end
  end
end
