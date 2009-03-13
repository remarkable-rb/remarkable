# Create an application controller to satisfy rspec-rails, a couple of dummy
# controllers and define routes.
#
class ApplicationController < ActionController::Base
end

class UsersController < ActionController::Base
end

class PostsController < ActionController::Base
end

# Define routes
ActionController::Routing::Routes.draw do |map|
  map.resources :users, :posts
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

