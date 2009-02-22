module Spec
  module Example
    module ExampleGroupMethods

      # This allows "describe User" to use the I18n human name of User.
      #
      def self.description_text(*args)
        args.inject("") do |description, arg|
          arg = arg.respond_to?(:human_name ) ? arg.human_name(:locale => Remarkable.locale) : arg.to_s
          description << " " unless (description == "" || arg =~ /^(\s|\.|#)/)
          description << arg
        end
      end

    end
  end
end
