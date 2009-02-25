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
      #   missing:
      #     allow_nil?: allowed the value to be nil
      #     allow_blank?: allowed the value to be blank
      #
      # Or you can set the message in the instance variable @missing in the
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

        assert_matcher do
          send_methods_and_generate_message(self.class.matcher_assertions)
        end &&
        assert_matcher_for(instance_variable_get("@#{self.class.matcher_arguments[:collection]}") || []) do |value|
          instance_variable_set("@#{self.class.matcher_arguments[:as]}", value)
          send_methods_and_generate_message(self.class.matcher_for_assertions)
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
        def default_i18n_options
          options = super.merge(collection_interpolation)

          # Add arguments to options
          self.class.matcher_arguments[:names].each do |name|
            options[name] = instance_variable_get("@#{name}").inspect
          end

          options
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

        # Helper that send the methods given and create a missing message if any
        # returns false. Since most assertion methods ends with an question
        # mark and it looks strange on I18n yml files, we also search for the
        # assertion method name without the question mark or exclamation mark
        # at the end. So if you have a method called is_valid? on I18n yml file
        # we will check for a key :is_valid? and :is_valid.
        #
        def send_methods_and_generate_message(methods)
          methods.each do |method|
            bool, hash = send(method)

            unless bool
              if @missing.nil?
                hash = default_i18n_options.merge(hash || {})

                if method.to_s =~ /\?|\!$/
                  hash[:default] = Array(hash[:default])
                  hash[:default] << :"missing.#{method.to_s.chop}"
                end

                @missing = Remarkable.t "missing.#{method}", hash
              end

              return false
            end
          end

          return true
        end

    end
  end
end
