module Remarkable # :nodoc:
  module Assertions
    # Asserts that two arrays contain the same elements, the same number of times.  Essentially ==, but unordered.
    #
    #   assert_same_elements([:a, :b, :c], [:c, :a, :b]) => passes
    def assert_same_elements(a1, a2, msg = nil)
      [:select, :inject, :size].each do |m|
        [a1, a2].each {|a| assert_respond_to(a, m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}.") }
      end

      assert a1h = a1.inject({}) { |h,e| h[e] = a1.select { |i| i == e }.size; h }
      assert a2h = a2.inject({}) { |h,e| h[e] = a2.select { |i| i == e }.size; h }

      assert_equal(a1h, a2h, msg)
    end

    # Asserts that the given matcher returns true when +target+ is passed to #matches?
    def assert_accepts(matcher, target)
      success = matcher.matches?(target)
      assert_block(matcher.failure_message) { success }
    end

    # Asserts that the given matcher returns false when +target+ is passed to #matches?
    def assert_rejects(matcher, target)
      success = !matcher.matches?(target)
      assert_block(matcher.negative_failure_message) { success }
    end
  end
end
