module Remarkable
  module DSL
    module Matches

      # For each instance under the collection declared in <tt>arguments</tt>,
      # this method will call each method declared in <tt>collection_assertions</tt>.
      #
      # As an example, let's assume you have the following matcher:
      #
      #   arguments  :collection => :attributes
      #   assertions :allow_nil?, :allow_blank?
      #
      # For each attribute in @attributes, we will set the instance variable
      # @attribute and then call allow_nil? and allow_blank?. Assertions should
      # return true if it pass or false if it fails. When it fails, it will use
      # I18n API to find the proper failure message:
      #
      #   expectations:
      #     allow_nil?: allowed the value to be nil
      #     allow_blank?: allowed the value to be blank
      #
      # Or you can set the message in the instance variable @expectation in the
      # assertion method if you don't want to rely on I18n API.
      #
      # This method also call the methods declared in single_assertions. Which
      # work the same way as assertions, except it doesn't loop for each value in
      # the collection.
      #
      # It also provides a before_assert callback that you might want to use it
      # to manipulate the subject before the assertions start.
      #
      def matches?(subject)
        @subject = subject

        run_before_assert_callbacks

        send_methods_and_generate_message(self.class.matcher_single_assertions) &&
        assert_matcher_for(instance_variable_get("@#{self.class.matcher_arguments[:collection]}") || []) do |value|
          instance_variable_set("@#{self.class.matcher_arguments[:as]}", value)
          send_methods_and_generate_message(self.class.matcher_collection_assertions)
        end
      end

      protected

        # Overwrite to provide default options.
        #
        def default_options
          {}
        end

        # Overwrites default_i18n_options to provide arguments and optionals
        # to interpolation options.
        #
        # If you still need to provide more other interpolation options, you can
        # do that in two ways:
        #
        # 1. Overwrite interpolation_options:
        #
        #   def interpolation_options
        #     { :real_value => real_value }
        #   end
        #
        # 2. Return a hash from your assertion method:
        #
        #   def my_assertion
        #     return true if real_value == expected_value
        #     return false, :real_value => real_value
        #   end
        #
        # In both cases, :real_value will be available as interpolation option.
        #
        def default_i18n_options #:nodoc:
          i18n_options = {}

          @options.each do |key, value|
            i18n_options[key] = value.inspect
          end if @options

          # Also add arguments as interpolation options.
          self.class.matcher_arguments[:names].each do |name|
            i18n_options[name] = instance_variable_get("@#{name}").inspect
          end

          # Add collection interpolation options.
          i18n_options.update(collection_interpolation)

          # Add default options (highest priority). They should not be overwritten.
          i18n_options.update(super)
        end

        # Method responsible to add collection as interpolation.
        #
        def collection_interpolation #:nodoc:
          options = {}

          if collection_name = self.class.matcher_arguments[:collection]
            collection_name = collection_name.to_sym
            collection = instance_variable_get("@#{collection_name}")
            options[collection_name] = array_to_sentence(collection) if collection

            object_name = self.class.matcher_arguments[:as].to_sym
            object = instance_variable_get("@#{object_name}")
            options[object_name] = object if object
          end

          options
        end

        # Send the assertion methods given and create a expectation message
        # if any of those methods returns false.
        #
        # Since most assertion methods ends with an question mark and it's not
        # readable in yml files, we remove question and exclation marks at the
        # end of the method name before translating it. So if you have a method
        # called is_valid? on I18n yml file we will check for a key :is_valid.
        #
        def send_methods_and_generate_message(methods) #:nodoc:
          methods.each do |method|
            bool, hash = send(method)

            unless bool
              parent_scope = matcher_i18n_scope.split('.')
              matcher_name = parent_scope.pop
              lookup       = :"expectations.#{method.to_s.gsub(/(\?|\!)$/, '')}"

              hash = { :scope => parent_scope, :default => lookup }.merge(hash || {})
              @expectation ||= Remarkable.t "#{matcher_name}.#{lookup}", default_i18n_options.merge(hash)

              return false
            end
          end

          return true
        end

    end
  end
end
