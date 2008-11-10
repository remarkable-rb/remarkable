module Remarkable
  class ProtectAttributes < Remarkable::Validation
    def initialize(*attributes)
      get_options!(attributes)
      @attributes = attributes
    end

    def matches?(klass)
      @klass = klass

      begin
        @attributes.each do |attribute|
          attribute = attribute.to_sym
          protected = klass.protected_attributes || []
          accessible = klass.accessible_attributes || []

          unless protected.include?(attribute.to_s) || (!accessible.empty? && !accessible.include?(attribute.to_s))
            message = if accessible.empty?
              "#{klass} is protecting #{protected.to_a.to_sentence}, but not #{attribute}."
            else
              "#{klass} has made #{attribute} accessible"
            end
            fail(message)
          end
        end

        true
      rescue Exception => e
        false
      end
    end

    def description
      "protect #{@attributes.to_sentence} from mass updates"
    end

    def failure_message
      "expected that #{@attributes.to_sentence} cannot be set on mass update, but it did"
    end

    def negative_failure_message
      "expected that #{@attributes.to_sentence} can be set on mass update, but it didn't"
    end
  end
end

# Ensures that the attribute cannot be set on mass update.
#
#   it { User.should protect_attributes(:password, :admin_flag) }
#
def protect_attributes(*attributes)
  Remarkable::ProtectAttributes.new(*attributes)
end
