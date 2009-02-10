module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ProtectAttributes < Remarkable::Matcher::Base
        def initialize(*attributes)
          attributes.extract_options!
          @attributes = attributes
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            protect_from_mass_updates?
          end
        end

        def description
          "protect #{@attributes.to_sentence} from mass updates"
        end
        
        private
        
        def protect_from_mass_updates?
          attribute  = @attribute.to_sym
          protected  = subject_class.protected_attributes || []
          accessible = subject_class.accessible_attributes || []

          return true if !protected.empty?  && protected.include?(attribute.to_s)
          return true if !accessible.empty? && !accessible.include?(attribute.to_s)

          @missing = accessible.empty? ? "#{subject_class} is protecting #{protected.to_a.to_sentence}, but not #{attribute}." :
                                         "#{subject_class} has made #{attribute} accessible"
          return false
        end
        
        def expectation
          "that #{@attribute} cannot be set on mass update"
        end
      end

      # TODO Deprecate this method and the matcher.
      def protect_attributes(*attributes) #:nodoc:
        warn "[DEPRECATION] should_protect_attributes is deprecated. " <<
             "Use should_not_allow_mass_assignment_of instead."
        ProtectAttributes.new(*attributes)
      end
    end
  end
end
