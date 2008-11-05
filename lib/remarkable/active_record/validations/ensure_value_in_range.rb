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

      unless assert_bad_value(klass, @attribute, @min - 1, @low_message)
        @message = "allow #{@attribute} to be less than #{@min}"
        return false
      end

      unless assert_good_value(klass, @attribute, @min, @low_message)
        @message = "not allow #{@attribute} to be #{@min}"
        return false
      end

      unless assert_bad_value(klass, @attribute, @max + 1, @high_message)
        @message = "allow #{@attribute} to be more than #{@max}"
        return false
      end

      unless assert_good_value(klass, @attribute, @max, @high_message)
        @message = "not allow #{@attribute} to be #{@max}"
        return false
      end

      true
    end

    def description
      "not allow #{@attribute} to be less than #{@min} and more than #{@max}"
    end

    def failure_message
      @message || "expected not allow #{@attribute} to be less than #{@min} and more than #{@max}, but it didn't"
    end

    def negative_failure_message
      "expected allow #{@attribute} to be less than #{@min} and more than #{@max}, but it did"
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
