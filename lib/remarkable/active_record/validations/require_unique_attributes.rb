module Remarkable
  class RequireUniqueAttributes < Remarkable::Validation
    def initialize(*attributes)
      @message, scope = get_options!(attributes, :message, :scoped_to)
      @scope = [*scope].compact
      @message ||= default_error_message(:taken)

      @attributes = attributes
    end

    def matches?(klass)
      @klass = klass

      begin
        @attributes.each do |attribute|
          attribute = attribute.to_sym

          existing = klass.find(:first)
          fail("Can't find first #{klass}") unless existing

          object = klass.new
          existing_value = existing.send(attribute)

          if !@scope.blank?
            @scope.each do |s|
              fail("#{klass.name} doesn't seem to have a #{s} attribute.") unless object.respond_to?(:"#{s}=")
              # assert_respond_to object, :"#{s}=", "#{klass.name} doesn't seem to have a #{s} attribute."
              object.send("#{s}=", existing.send(s))
            end
          end
          return false unless assert_bad_value(object, attribute, existing_value, @message)

          # Now test that the object is valid when changing the scoped attribute
          # TODO:  There is a chance that we could change the scoped field
          # to a value that's already taken.  An alternative implementation
          # could actually find all values for scope and create a unique
          # one.
          if !@scope.blank?
            @scope.each do |s|
              # Assume the scope is a foreign key if the field is nil
              object.send("#{s}=", existing.send(s).nil? ? 1 : existing.send(s).next)
              return false unless assert_good_value(object, attribute, existing_value, @message)
            end
          end
        end

        true
      rescue Exception => e
        false
      end
    end

    def description
      "require unique value for #{@attributes.to_sentence}#{" scoped to #{@scope.to_sentence}" unless @scope.blank?}"
    end

    def failure_message
      @failure_message || "expected that the #{@klass.name} cannot be saved if #{@attributes.to_sentence}#{" scoped to #{@scope.to_sentence}" unless @scope.blank?} is not unique, but it did"
    end

    def negative_failure_message
      "expected that the #{@klass.name} can be saved if #{@attributes.to_sentence}#{" scoped to #{@scope.to_sentence}" unless @scope.blank?} is not unique, but it didn't"
    end
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
#   should_require_unique_attributes :keyword, :username
#   should_require_unique_attributes :name, :message => "O NOES! SOMEONE STOELED YER NAME!"
#   should_require_unique_attributes :email, :scoped_to => :name
#   should_require_unique_attributes :address, :scoped_to => [:first_name, :last_name]
#
def require_unique_attributes(*attributes)
  Remarkable::RequireUniqueAttributes.new(*attributes)
end
