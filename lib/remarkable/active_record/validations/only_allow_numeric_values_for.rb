module Remarkable
  class OnlyAllowNumericValuesFor < Remarkable::Validation
    def initialize(*attributes)
      @message = get_options!(attributes, :message)
      @message ||= default_error_message(:not_a_number)
      
      @attributes = attributes
    end

    def matches?(klass)
      @klass = klass

      begin
        @attributes.each do |attribute|
          attribute = attribute.to_sym
          return false unless assert_bad_value(klass, attribute, "abcd", @message)
        end
        
        true
      rescue Exception => e
        false
      end
    end

    def description
      "only allow numeric values for #{@attributes.to_sentence}"
    end

    def failure_message
      "expected only numeric values for #{@attributes.to_sentence}, but it didn't"
    end

    def negative_failure_message
      "expected not only numeric values for #{@attributes.to_sentence}, but it did"
    end
  end
end

# Ensure that the attribute is numeric
#
# If an instance variable has been created in the setup named after the
# model being tested, then this method will use that.  Otherwise, it will
# create a new instance to test against.
#
# Options:
# * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
#   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.not_a_number')</tt>
#
# Example:
#   it { User.should only_allow_numeric_values_for(:age) }
#
def only_allow_numeric_values_for(*attributes)
  Remarkable::OnlyAllowNumericValuesFor.new(*attributes)
end
