# Remarkable core module
module Remarkable
  # A module that keeps all matchers added. This is useful because it allows
  # to include matchers in Test::Unit as well.
  module Matchers; end

  # Helper that includes required Remarkable modules into the given klass.
  #
  # If the module to be included responds to :after_include, it's called with the
  # target as argument.
  #
  def self.include_matchers!(base, target=nil)
    if target.nil?
      if rspec_defined?
        target = RSpec::Matchers
      else
        raise ArgumentError, "You haven't supplied the target to include_matchers! and RSpec is not loaded, so we cannot infer one."
      end
    end

    metaclass = (class << target; self; end)
    target.send :extend, Remarkable::Macros  unless metaclass.ancestors.include?(Remarkable::Macros)

    if defined?(base::Matchers)
      target.send :include, base::Matchers

      Remarkable::Matchers.send :extend, base::Matchers
      Remarkable::Matchers.send :include, base::Matchers
    end

    if base.respond_to?(:after_include)
      base.after_include(target)
    end
  end

  def self.rspec_defined? #:nodoc:
    defined?(RSpec)
  end
end
