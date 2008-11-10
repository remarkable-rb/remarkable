include Remarkable::Private

# Ensures that the model cannot be saved if one of the attributes listed is not present.
#
# If an instance variable has been created in the setup named after the
# model being tested, then this method will use that.  Otherwise, it will
# create a new instance to test against.
#
# Options:
# * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
#   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.blank')</tt>
#
# Example:
#   should_require_attributes :name, :phone_number
#
def should_require_attributes(*attributes)
  message = get_options!(attributes, :message)
  message ||= default_error_message(:blank)
  klass = model_class

  attributes.each do |attribute|
    it "require #{attribute} to be set" do
      assert_bad_value(klass, attribute, nil, message)
    end
  end
end
