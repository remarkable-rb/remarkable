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
def should_route(method, path, params)
  populated_path = path.dup

  params[:controller] = params[:controller].to_s
  params[:action] = params[:action].to_s

  params.each do |key, value|
    params[key] = value.to_param if value.respond_to? :to_param
    populated_path.gsub!(key.inspect, value.to_s)
  end

  it "should map #{params.inspect} to #{path.inspect}" do
    route_for(params).should == populated_path
  end

  it "should generate params #{params.inspect} from #{method.to_s.upcase} to #{path.inspect}" do
    params_from(method.to_sym, populated_path).should == params
  end
end
