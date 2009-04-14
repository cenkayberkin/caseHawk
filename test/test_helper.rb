ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'shoulda'
require 'mocha'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all

  def logout
    @controller.send :current_user=, nil
    session[:user] = nil
  end

  def login(user)
    logout
    session[:user] = user.id
    @controller.send :current_user=, user
  end  
end
