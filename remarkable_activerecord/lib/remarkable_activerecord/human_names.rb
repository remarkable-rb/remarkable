if defined?(Spec)
  module Spec
    module Example
      module ExampleGroupMethods

        # This allows "describe User" to use the I18n human name of User.
        #
        def self.build_description_with_i18n(*args)
          args.inject("") do |description, arg|
            arg = if RAILS_I18N && arg.respond_to?(:human_name)
              arg.human_name(:locale => Remarkable.locale)
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
        def build_description_from(*args)
          text = ExampleGroupMethods.build_description_with_i18n(*args)
          text == "" ? nil : text
        end

      end
    end
  end
end

module Remarkable
  module ActiveRecord
    class Base < Remarkable::Base

      protected

        # Changes collection_interpolation method to provide the attribute's
        # localized names whenever is possible.
        #
        def collection_interpolation
          described_class = if @subject
            subject_class
          elsif @spec
            @spec.send(:described_class)
          end

          if described_class.respond_to?(:human_attribute_name) && RAILS_I18N && self.class.matcher_arguments[:collection] == :attributes
            options = {}

            if collection = instance_variable_get('@attributes')
              collection.map!{|attr| described_class.human_attribute_name(attr.to_s, :locale => Remarkable.locale).downcase }
              options[:attributes] = array_to_sentence(collection)
            end

            if object = instance_variable_get('@attribute')
              object = described_class.human_attribute_name(object.to_s, :locale => Remarkable.locale).downcase
              options[:attribute] = object
            end

            options
          else
            super
          end
        end

    end
  end
end
