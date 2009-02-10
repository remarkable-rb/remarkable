module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class AllowMassAssignmentOfMatcher < Remarkable::Matcher::Base
        def initialize(*attributes)
          attributes.extract_options!
          @attributes = attributes
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            allowed_to_mass_update?
          end
        end

        def description
          "allow mass assignment of #{@attributes.to_sentence}"
        end

        private

        def allowed_to_mass_update?
          attribute  = @attribute.to_sym
          protected  = subject_class.protected_attributes || []
          accessible = subject_class.accessible_attributes || []

          return true if !protected.empty?  && !protected.include?(attribute.to_s)
          return true if !accessible.empty? && accessible.include?(attribute.to_s)

          @missing = accessible.empty? ? "#{subject_class} is protecting #{protected.to_a.to_sentence}" :
                                         "#{subject_class} has not made #{attribute} accessible"
          return false
        end

        def expectation
          "to allow mass assignment of #{@attribute}"
        end
      end

      # Ensures that the attribute can be set on mass update.
      #
      #   it { should allow_mass_assignment_of(:email, :name) }
      #
      def allow_mass_assignment_of(*attributes)
        AllowMassAssignmentOfMatcher.new(*attributes)
      end
    end
  end
end
