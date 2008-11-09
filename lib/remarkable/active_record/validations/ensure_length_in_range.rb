module Remarkable
  class EnsureLengthInRange < Remarkable::Validation
    def initialize(attribute, range, opts)
      @min_length  = range.first
      @max_length  = range.last
      @same_length = (@min_length == @max_length)

      @attribute = attribute
      @range     = range
      @opts      = opts
    end

    def matches?(klass)
      @klass = klass

      begin
        if @min_length > 0
          min_value = "x" * @min_length
          fail("not allow #{@attribute} to be exactly #{@min_length} chars long") unless assert_good_value(klass, @attribute, min_value, /is too short/)
        end

        unless @same_length
          max_value = "x" * @max_length
          fail("not allow #{@attribute} to be exactly #{@max_length} chars long") unless assert_good_value(klass, @attribute, max_value, /is too long/)
        end

        if @min_length > 0
          min_value = "x" * (@min_length - 1)
          fail("allow #{@attribute} to be less than #{@min_length} chars long") unless assert_bad_value(klass, @attribute, min_value, /is too short/)
        end

        max_value = "x" * (@max_length + 1)
        fail("allow #{@attribute} to be more than #{@max_length} chars long") unless assert_bad_value(klass, @attribute, max_value, /is too long/)

        true
      rescue Exception => e
        false
      end
    end

    def description
      "ensure that the length of the #{@attribute} is in #{@range}"
    end

    def failure_message
      @failure_message || "expected that the length of the #{@attribute} is in #{@range}, but it didn't"
    end

    def negative_failure_message
      "expected that the length of the #{@attribute} isn't in #{@range}, but it did"
    end
  end
end

# Ensures that the length of the attribute is in the given range
#
# If an instance variable has been created in the setup named after the
# model being tested, then this method will use that.  Otherwise, it will
# create a new instance to test against.
#
# Options:
# * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
#   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % range.first</tt>
# * <tt>:long_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
#   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_long') % range.last</tt>
#
# Example:
#   it { User.should ensure_length_in_range(:password, 6..20) }
#
def ensure_length_in_range(attribute, range, opts = {})
  Remarkable::EnsureLengthInRange.new(attribute, range, opts)
end
