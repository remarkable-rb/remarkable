module Remarkable
  module ActiveRecord

    def self.after_include(target)
      target.class_inheritable_reader :default_subject_attributes
      target.extend Describe
    end

    module Describe

      # Overwrites describe to provide quick way to configure your subject:
      #
      #   describe Post
      #     should_validate_presente_of :title
      #
      #     describe :published => true do
      #       should_validate_presence_of :published_at
      #     end
      #   end
      #
      # This is the same as:
      #
      #   describe Post
      #     should_validate_presente_of :title
      #
      #     describe "when published is true" do
      #       subject { Post.new(:published => true) }
      #       should_validate_presence_of :published_at
      #     end
      #   end
      #
      # The string can be localized using I18n. An example yml file is:
      #
      #   locale:
      #     remarkable:
      #       active_record:
      #         describe:
      #           each: "{{key}} is {{value}}"
      #           prepend: "when "
      #           connector: " and "
      #
      def describe(*args, &block)
        if described_class && args.first.is_a?(Hash)
          attributes = args.shift

          connector = Remarkable.t "remarkable.active_record.describe.connector", :default => " and "

          description = if self.default_subject_attributes.blank?
            Remarkable.t("remarkable.active_record.describe.prepend", :default => "when ")
          else
            connector.lstrip
          end

          pieces = []
          attributes.each do |key, value|
            translated_key = if described_class.respond_to?(:human_attribute_name)
              described_class.human_attribute_name(key, :locale => Remarkable.locale)
            else
              key.to_s.humanize
            end

            pieces << Remarkable.t("remarkable.active_record.describe.each",
                                    :default => "{{key}} is {{value}}",
                                    :key => key, :value => value.inspect)
          end

          description << pieces.join(connector)
          args.unshift(description)

          # Creates an example group, send the method and eval the given block.
          #
          example_group = super(*args) do
            write_inheritable_hash(:default_subject_attributes, attributes)
            subject { self.class.described_class.new(self.class.default_subject_attributes) }
            instance_eval(&block)
          end
        else
          super(*args, &block)
        end
      end

    end
  end
end
