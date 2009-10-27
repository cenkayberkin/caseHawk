require File.dirname(__FILE__) + '/../test_helper'

class SessionsControllerTest < ActionController::TestCase

  context "sessions" do
    should 'login and redirect' do
      post :create, :login => 'quentin', :password => 'longpassword'
      assert session[:user_id]
      assert_response :redirect, @response.body
    end
  
    should 'fail login and not redirect' do
      post :create, :login => 'quentin', :password => 'bad password'
      assert !session[:user_id]
      assert_response :ok, @response.body
    end

    should 'log out' do
      login_as :quentin
      get :destroy
      assert !session[:user_id]
      assert_response :redirect, @response.body
    end

    should 'remember me' do
      post :create, :login => 'quentin', :password => 'longpassword', :remember_me => "1"
      assert @response.cookies["auth_token"]
    end
  
    should 'doe not remember me' do
      post :create, :login => 'quentin', :password => 'longpassword', :remember_me => "0"
      assert !@response.cookies["auth_token"]
    end

    should 'delete token on logout' do
      login_as :quentin
      get :destroy
      assert @response.cookies["auth_token"].blank?
    end

    should 'log in with cookie' do
      users(:quentin).remember_me
      @request.cookies["auth_token"] = cookie_for(:quentin)
      get :new
      assert @controller.send(:logged_in?)
    end
  
    should 'fail expired cookie login' do
      users(:quentin).remember_me
      users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
      @request.cookies["auth_token"] = cookie_for(:quentin)
      get :new
      assert !@controller.send(:logged_in?)
    end
  
    should 'fails cookie login' do
      users(:quentin).remember_me
      @request.cookies["auth_token"] = auth_token('invalid_auth_token')
      get :new
      assert !@controller.send(:logged_in?)
    end
  end
  

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(user)
    auth_token users(user).remember_token
  end
end
