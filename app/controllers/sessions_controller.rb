# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  skip_before_filter :login_required, :except => :destroy
  def new
    if start_openid_from_google?
      start_open_id_authentication
    elsif using_open_id?
      open_id_authentication
    end
  end
  
  def create
    self.current_user = current_account.users.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_to('/')
      flash[:notice] = "Logged in successfully"
    else
      flash.now[:error] = 'Invalid login credentials'
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to('/')
  end
  
  def login_from_openid
      open_id_authentication and return
    false
  end
  
  def start_openid_from_google?
    params[:from] == 'google' && !params[:domain].blank?
  end
  
  def start_open_id_authentication
    authenticate_with_open_id(params[:domain], {:required => "http://axschema.org/contact/email"})
  end
  
  def open_id_authentication
    authenticate_with_open_id() do |result, identity_url|
      if result.successful?
        ax = OpenID::AX::FetchResponse.from_success_response(request.env[Rack::OpenID::RESPONSE])
        session[:user_attributes] = {
          :email => ax.get_single("http://axschema.org/contact/email"),
          :first_name => ax.get_single("http://axschema.org/namePerson/first"),
          :last_name => ax.get_single("http://axschema.org/namePerson/last")
        }
        raise ax.inspect + session.inspect
      else
        flash[:error] = result.message || "Sorry, no user by that identity URL exists (#{identity_url})"
        @remember_me = params[:remember_me]
        render :action => 'new'
      end
    end
  end
end
