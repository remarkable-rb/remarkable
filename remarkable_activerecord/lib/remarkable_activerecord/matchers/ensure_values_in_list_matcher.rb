module Remarkable
  module ActiveRecord
    module Matchers
      class EnsureValuesInListMatcher < Remarkable::ActiveRecord::Base
        arguments :behavior, :collection => :attributes, :as => :attribute

        optional :message
        optional :allow_nil, :allow_blank, :default => true

        collection_assertions :is_valid?, :allow_nil?, :allow_blank?

        after_initialize do
          @options[:message] ||= @behavior
          @options[:in]        = [*@options[:in]].compact
        end

        protected

          def is_valid?
            @options[:in].each do |value|
              if @behavior == :exclusion
                return false, :value => value.inspect unless bad?(value)
              else
                return false, :value => value.inspect unless good?(value)
              end
            end

            return true
          end

          def interpolation_options
            { :in => @options[:in].map(&:inspect).to_sentence, :behavior => @behavior.to_s }
          end

      end
    end
  end
end
