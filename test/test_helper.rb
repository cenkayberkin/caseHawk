ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'shoulda'
require 'mocha'

class ActiveSupport::TestCase

  include AuthenticatedTestHelper
  def logout
    @controller.send :current_user=, nil
    session[:user_id] = nil
  end

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all

  def valid_address(attributes = {})
    {
      :first_name => 'John',
      :last_name => 'Doe',
      :address1 => '2010 Cherry Ct.',
      :city => 'Mobile',
      :state => 'AL',
      :zip => '36608',
      :country => 'US'
    }.merge(attributes)
  end
  
  def valid_card(attributes = {})
    { :first_name => 'Joe', 
      :last_name => 'Doe',
      :month => 2, 
      :year => Time.now.year + 1, 
      :number => '1', 
      :type => 'bogus', 
      :verification_value => '123' 
    }.merge(attributes)
  end
  
  def valid_user(attributes = {})
    { :name => 'Bubba',
      :login => 'foobar',
      :password => 'foobar', 
      :password_confirmation => 'foobar',
      :email => "bubba@#{AppConfig['base_domain']}"
    }.merge(attributes)
  end
end
