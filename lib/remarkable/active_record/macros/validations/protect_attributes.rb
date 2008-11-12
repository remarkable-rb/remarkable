module Remarkable
  module Syntax

    module RSpec
      class ProtectAttributes
        include Remarkable::Private
        
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

      # Ensures that the attribute cannot be set on mass update.
      #
      #   it { User.should protect_attributes(:password, :admin_flag) }
      #
      def protect_attributes(*attributes)
        Remarkable::Syntax::RSpec::ProtectAttributes.new(*attributes)
      end
    end

    module Shoulda
      # Ensures that the attribute cannot be set on mass update.
      #
      #   should_protect_attributes :password, :admin_flag
      #
      def should_protect_attributes(*attributes)
        get_options!(attributes)
        klass = model_class

        attributes.each do |attribute|
          attribute = attribute.to_sym
          it "should protect #{attribute} from mass updates" do
            protected = klass.protected_attributes || []
            accessible = klass.accessible_attributes || []

            unless protected.include?(attribute.to_s) || (!accessible.empty? && !accessible.include?(attribute.to_s))
              message = if accessible.empty?
                "#{klass} is protecting #{protected.to_a.to_sentence}, but not #{attribute}."
              else
                "#{klass} has made #{attribute} accessible"
              end
              fail_with(message)
            end
          end
        end
      end
    end

  end
end
