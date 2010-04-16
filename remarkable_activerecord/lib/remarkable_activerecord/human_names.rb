if defined?(Rspec)
  module Rspec #:nodoc:
    module Example #:nodoc:
      module ExampleGroupMethods #:nodoc:

        # This allows "describe User" to use the I18n human name of User.
        #
        def self.build_description_with_i18n(*args)
          args.inject("") do |description, arg|
            arg = if arg.respond_to?(:model_name)
              arg.model_name.human(:locale => Remarkable.locale)
            else
              arg.to_s
            end

            description << " " unless (description == "" || arg =~ /^(\s|\.|#)/)
            description << arg
          end
        end

        # This is for rspec <= 1.1.12.
        #
        def self.description_text(*args)
          self.build_description_with_i18n(*args)
        end

        # This is for rspec >= 1.2.0.
        #
        def self.build_description_from(*args)
          text = ExampleGroupMethods.build_description_with_i18n(*args)
          text == "" ? nil : text
        end

      end
    end
  end
end
