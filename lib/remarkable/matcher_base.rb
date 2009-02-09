module Remarkable # :nodoc:
  module Matcher # :nodoc:
    class Base

      # Creates optional handlers for matchers dynamically. The following
      # statement:
      #
      #   optional :range, :default => 0..10
      #
      # Will generate:
      #
      #   def range(value=0..10)
      #     @options ||= {}
      #     @options[:range] = value
      #     self
      #   end
      #
      # Options:
      #
      # * <tt>:default</tt> - The default value for this optional
      # * <tt>:alias</tt>  - An alias for this optional
      #
      # Examples:
      #
      #   optional :name, :title
      #   optional :range, :default => 0..10, :alias => :within
      #
      def self.optional(*names)
        options = names.extract_options!
        names.each do |name|
          class_eval <<-END
def #{name}(value#{ options[:default] ? "=#{options[:default].inspect}" : "" })
  @options ||= {}
  @options[:#{name}] = value
  self
end
END
          class_eval "alias_method(:#{options[:alias]}, :#{name})" if options[:alias]
        end
      end

      def negative
        @negative = true
        self
      end

      def failure_message
        "Expected #{expectation} (#{@missing})"
      end

      def negative_failure_message
        "Did not expect #{expectation}"
      end

      def spec(spec)
        @spec = spec
        self
      end

      private

      def subject_class
        @subject.is_a?(Class) ? @subject : @subject.class
      end

      def subject_name
        subject_class.name
      end

      def positive?
        @negative ? false : true
      end

      def negative?
        @negative ? true : false
      end

      def assert_matcher(&block)
        if positive?
          return false unless yield
        else
          return true if yield
        end
        positive?
      end

      def assert_matcher_for(collection, &block)
        collection.each do |item|
          if positive?
            return false unless yield(item)
          else
            return true if yield(item)
          end
        end
        positive?
      end

    end
  end
end
