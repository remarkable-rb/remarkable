module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class RequireUniqueAttributes < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(*attributes)
          load_options(attributes.extract_options!)
          @attributes = attributes
        end

        def message(message)
          @options[:message] = message
          self
        end
        
        def scoped_to(scoped)
          @options[:scoped_to] = [*scoped].compact
          self
        end

        def matches?(subject)
          @subject = subject
          
          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            
            find_first_object? &&
            have_attribute? &&
            valid_when_changing_scoped_attribute?
          end
        end

        def description
          "require unique value for #{@attributes.to_sentence}#{" scoped to #{scope.to_sentence}" unless scope.blank?}"
        end
        
        private
        
        def scope
          @options[:scoped_to]
        end
        
        def find_first_object?
          return true if @existing = model_class.find(:first)
          
          @missing = "Can't find first #{model_class}"
          return false
        end
        
        def have_attribute?
          @object = model_class.new
          @existing_value = @existing.send(@attribute)
          
          if !scope.blank?
            scope.each do |s|
              unless @object.respond_to?(:"#{s}=")
                @missing = "#{model_name} doesn't seem to have a #{s} attribute."
                return false
              end
              @object.send("#{s}=", @existing.send(s))
            end
          end

          return true if assert_bad_value(@object, @attribute, @existing_value, @options[:message])

          @missing = "not require unique value for #{@attribute}#{" scoped to #{scope.join(', ')}" unless scope.blank?}"
          return false
        end
        
        # Now test that the object is valid when changing the scoped attribute
        # TODO:  There is a chance that we could change the scoped field
        # to a value that's already taken.  An alternative implementation
        # could actually find all values for scope and create a unique
        # one.
        def valid_when_changing_scoped_attribute?
          if !scope.blank?
            scope.each do |s|
              # Assume the scope is a foreign key if the field is nil
              @object.send("#{s}=", @existing.send(s).nil? ? 1 : @existing.send(s).next)
              unless assert_good_value(@object, @attribute, @existing_value, @options[:message])
                @missing = "#{model_name} is not valid when changing the scoped attribute for #{s}"
                return false
              end
            end
          end
          true
        end
        
        def load_options(options)
          @options = {
            :message => default_error_message(:taken)
          }.merge(options)
          @options[:scoped_to] = [*options[:scoped_to]].compact
        end
        
        def expectation
          "that the #{model_name} cannot be saved if #{@attribute}#{" scoped to #{scope.to_sentence}" unless scope.blank?} is not unique"
        end
      end

      # Ensures that the model cannot be saved if one of the attributes listed is not unique.
      # Requires an existing record
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.taken')</tt>
      # * <tt>:scoped_to</tt> - field(s) to scope the uniqueness to.
      #
      # Examples:
      #   it { should require_unique_attributes(:keyword, :username) }
      #   it { should require_unique_attributes(:name, :message => "O NOES! SOMEONE STOELED YER NAME!") }
      #   it { should require_unique_attributes(:email, :scoped_to => :name) }
      #   it { should require_unique_attributes(:address, :scoped_to => [:first_name, :last_name]) }
      #
      def require_unique_attributes(*attributes)
        RequireUniqueAttributes.new(*attributes)
      end
    end
  end
end
