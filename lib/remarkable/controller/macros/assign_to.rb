module Remarkable
  module Controller
    module Syntax

      module RSpec
        # Macro that creates a test asserting that the controller assigned to
        # each of the named instance variable(s).
        #
        # Options:
        # * <tt>:class</tt> - The expected class of the instance variable being checked.
        # * <tt>:equals</tt> - A string which is evaluated and compared for equality with
        # the instance variable being checked.
        #
        # Example:
        #
        #   it { should assign_to(:user, :posts) }
        #   it { should assign_to(:user, :class => User) }
        #   it { should assign_to(:user, :equals => '@user') }
        #   it { should_not assign_to(:user, :posts) }
        # 
        def assign_to(*names)
          opts = names.extract_options!
          test_name = "assign @#{names.to_sentence}"
          test_name << " as class #{opts[:class]}" if opts[:class]
          test_name << " which is equal to #{opts[:equals]}" if opts[:equals]

          simple_matcher test_name do |controller, matcher|
            ret = true
            names.each do |name|
              assigned_value = assigns(name.to_sym)

              unless assigned_value
                ret = false
                break
              end

              if opts[:class]
                unless assigned_value.kind_of?(opts[:class])
                  ret = false
                  break
                end
              end

              if opts[:equals]
                instantiate_variables_from_assigns do
                  expected_value = eval(opts[:equals], self.send(:binding), __FILE__, __LINE__)
                  unless assigned_value == expected_value
                    ret = false
                    break
                  end
                end
              end
            end

            ret
          end
        end
      end

      module Shoulda
        # Macro that creates a test asserting that the controller assigned to
        # each of the named instance variable(s).
        #
        # Options:
        # * <tt>:class</tt> - The expected class of the instance variable being checked.
        # * <tt>:equals</tt> - A string which is evaluated and compared for equality with
        # the instance variable being checked.
        #
        # Example:
        #
        #   should_assign_to :user, :posts
        #   should_assign_to :user, :class => User
        #   should_assign_to :user, :equals => '@user'
        # 
        def should_assign_to(*names)
          opts = names.extract_options!
          names.each do |name|
            test_name = "should assign @#{name}"
            test_name << " as class #{opts[:class]}" if opts[:class]
            test_name << " which is equal to #{opts[:equals]}" if opts[:equals]
            it test_name do
              assigned_value = assigns(name.to_sym)
              assigned_value.should_not be_nil
              assigned_value.should be_a_kind_of(opts[:class]) if opts[:class]
              if opts[:equals]
                instantiate_variables_from_assigns do
                  expected_value = eval(opts[:equals], self.send(:binding), __FILE__, __LINE__)
                  assigned_value.should == expected_value
                end
              end
            end
          end
        end

        # Macro that creates a test asserting that the controller did not assign to
        # any of the named instance variable(s).
        #
        # Example:
        #
        #   should_not_assign_to :user, :posts
        # 
        def should_not_assign_to(*names)
          names.each do |name|
            it "should not assign to @#{name}" do
              assigns(name.to_sym).should be_nil
            end
          end
        end

      end
    end
  end
end
