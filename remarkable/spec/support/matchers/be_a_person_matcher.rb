module Remarkable
  module RSpec
    module Matchers
      class BeAPersonMatcher < Remarkable::Base
        arguments

        optional :first_name
        optional :age, :default => 18
        optional :last_name, :alias => :family_name
        optional :bands, :splat => true
        optional :builder, :block => true

        attr_reader :options

        def description
          "be a person"
        end

        def expectation
          "is not a person"
        end
      end

      def be_a_person(*args, &block)
        BeAPersonMatcher.new(*args, &block).spec(self)
      end
    end
  end
end
