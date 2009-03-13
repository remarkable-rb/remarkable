module Remarkable
  module DSL
    module Matches

      # For each instance under the collection declared in <tt>arguments</tt>,
      # this method will call each method declared in <tt>assertions</tt>.
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

        # Overwrites default_i18n_options to provide arguments and collection
        # interpolation.
        #
        # Optionals are, by default, not available as interpolation options
        # because they will be automatically appended do descriptions. If you
        # need them to create an expectation message, you can do it in two ways:
        #
        # 1. Overwrite default_i18n_options:
        #
        #   def default_i18n_options
        #     super.update(:real_value => real_value)
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
        def default_i18n_options
          i18n_options = {}

          # Also add arguments as interpolation options.
          self.class.matcher_arguments[:names].each do |name|
            i18n_options[name] = instance_variable_get("@#{name}").inspect
          end

          # Add collection interpolation options.
          i18n_options.update(collection_interpolation)

          # Add default options (highest priority). They should not be overwritten.
          i18n_options.update(super)
        end

        # Methods that return collection_name and object_name as a Hash for
        # interpolation.
        #
        def collection_interpolation
          options = {}

          # Add collection to options
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

        # Helper that send the methods given and create a expectation message if
        # any returns false. Since most assertion methods ends with an question
        # mark and it looks strange on I18n yml files, we also search for the
        # assertion method name without the question mark or exclamation mark
        # at the end. So if you have a method called is_valid? on I18n yml file
        # we will check for a key :is_valid? and :is_valid.
        #
        def send_methods_and_generate_message(methods)
          methods.each do |method|
            bool, hash = send(method)

            unless bool
              if @expectation.nil?
                hash = default_i18n_options.merge(hash || {})

                if method.to_s =~ /\?|\!$/
                  hash[:default] = Array(hash[:default])
                  hash[:default].unshift(:"expectations.#{method.to_s.chop}")
                end

                @expectation = Remarkable.t "expectations.#{method}", hash
              end

              return false
            end
          end

          return true
        end

    end
  end
end
