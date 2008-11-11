# Macro that creates a routing test. It tries to use the given HTTP
# +method+ on the given +path+, and asserts that it routes to the
# given +options+.
#
# +to_param+ is called on the +options+ given.
#
# Examples:
#
#   should_route :get, "/posts", :controller => :posts, :action => :index
#   should_route :get, "/posts/new", :controller => :posts, :action => :new
#   should_route :post, "/posts", :controller => :posts, :action => :create
#   should_route :get, "/posts/1", :controller => :posts, :action => :show, :id => 1
#   should_route :edit, "/posts/1", :controller => :posts, :action => :show, :id => 1
#   should_route :put, "/posts/1", :controller => :posts, :action => :update, :id => 1
#   should_route :delete, "/posts/1", :controller => :posts, :action => :destroy, :id => 1
#   should_route :get, "/users/1/posts/1",
#     :controller => :posts, :action => :show, :id => 1, :user_id => 1
#
def should_route(method, path, options)
  populated_path = path.dup
  
  unless options[:controller]
    it "should explicitly specify :controller" do
      options[:controller].should_not be_nil
    end
    return
  end
  
  options[:controller] = options[:controller].to_s
  options[:action] = options[:action].to_s

  options.each do |key, value|
    options[key] = value.to_param if value.respond_to? :to_param
    populated_path.gsub!(key.inspect, value.to_s)
  end

  it "should map #{options.inspect} to #{path.inspect}" do
    route_for(options).should == populated_path
  end

  it "should generate params #{options.inspect} from #{method.to_s.upcase} to #{path.inspect}" do
    params_from(method.to_sym, populated_path).should == options
  end
end

def route(method, path, options)
  simple_matcher "route #{method.to_s.upcase} #{path} to/from #{options.inspect}" do |controller|
    unless options[:controller]
      options[:controller] = controller.name.gsub(/Controller$/, '').tableize
    end
    options[:controller] = options[:controller].to_s
    options[:action] = options[:action].to_s

    populated_path = path.dup
    options.each do |key, value|
      options[key] = value.to_param if value.respond_to? :to_param
      populated_path.gsub!(key.inspect, value.to_s)
    end
    
    route_for(options).should == populated_path && params_from(method.to_sym, populated_path).should == options
  end
end
