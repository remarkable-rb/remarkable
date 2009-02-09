module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class HaveReadonlyAttributes < Remarkable::Matcher::Base
        def initialize(*attributes)
          attributes.extract_options!
          @attributes = attributes
        end

        def matches?(subject)
          @subject = subject
          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            attribute_readonly?
          end
        end

        def description
          "make #{@attributes.to_sentence} read-only"
        end

        private

        def attribute_readonly?
          attribute = @attribute.to_sym
          readonly = subject_class.readonly_attributes || []
          return true if readonly.include?(attribute.to_s)

          @missing = (readonly.empty? ? "#{subject_class} attribute #{attribute} is not read-only" :
                                        "#{subject_class} is making #{readonly.to_a.to_sentence} read-only, but not #{attribute}.")
          return false
        end
        
        def expectation
          "that #{@attribute} cann be changed once the record has been created"
        end
      end

      # Ensures that the attribute cannot be changed once the record has been created.
      #
      #   it { should have_readonly_attributes(:password, :admin_flag) }
      #
      def have_readonly_attributes(*attributes)
        HaveReadonlyAttributes.new(*attributes)
      end
    end
  end
end
