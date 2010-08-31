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
    if params[:apps_email].nil?
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
    else
      redirect_to new_session_path( :domain => params[:apps_email].split('@')[1], :from => 'google')
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
    authenticate_with_open_id(params[:domain], {
      :required => [
        "http://axschema.org/contact/email",
        "http://axschema.org/namePerson/first",
        "http://axschema.org/namePerson/last",
        "http://axschema.org/media/image/aspect11"
      ], 
      :scope => "https://www.google.com/calendar/feeds/"
    })
  end
  
  def open_id_authentication
    authenticate_with_open_id() do |result, identity_url|
      if result.successful?
        ax = OpenID::AX::FetchResponse.from_success_response(request.env[Rack::OpenID::RESPONSE])
        self.current_user = User.find_by_email(ax.get_single("http://axschema.org/contact/email"))
        redirect_to('/')
        flash[:notice] = "Logged in successfully"
      else
        flash.now[:error] = 'You must allow CaseHawk access to your Google Apps account.'
        render :action => 'new'
      end
    end
  end
end
