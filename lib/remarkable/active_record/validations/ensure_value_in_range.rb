module Remarkable
  class EnsureValueInRange < Remarkable::Validation
    def initialize(attribute, range, opts = {})
      @attribute = attribute
      @range     = range
      @opts      = opts

      @min = range.first
      @max = range.last

      @low_message, @high_message = get_options!([@opts], :low_message, :high_message)
      @low_message  ||= default_error_message(:inclusion)
      @high_message ||= default_error_message(:inclusion)
    end

    def matches?(klass)
      @klass = klass

      begin
        fail("allow #{@attribute} to be less than #{@min}") unless assert_bad_value(klass, @attribute, @min - 1, @low_message)
        fail("not allow #{@attribute} to be #{@min}") unless assert_good_value(klass, @attribute, @min, @low_message)
        fail("allow #{@attribute} to be more than #{@max}") unless assert_bad_value(klass, @attribute, @max + 1, @high_message)
        fail("not allow #{@attribute} to be #{@max}") unless assert_good_value(klass, @attribute, @max, @high_message)
        
        true
      rescue Exception => e
        false
      end
    end

    def description
      "ensure that the #{@attribute} is in #{@range}"
    end

    def failure_message
      @failure_message || "expected that the #{@attribute} is in #{@range}, but it didn't"
    end

    def negative_failure_message
      "expected that the #{@attribute} isn't in #{@range}, but it did"
    end
  end
end

# Ensure that the attribute is in the range specified
#
# If an instance variable has been created in the setup named after the
# model being tested, then this method will use that.  Otherwise, it will
# create a new instance to test against.
#
# Options:
# * <tt>:low_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
#   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
# * <tt>:high_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
#   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
#
# Example:
#   it { User.should ensure_value_in_range(:age, 1..100) }
#
def ensure_value_in_range(attribute, range, opts = {})
  Remarkable::EnsureValueInRange.new(attribute, range, opts)
end
