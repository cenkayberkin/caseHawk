# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include SslRequirement
  
  before_filter :login_required
  
  helper :all # include all helpers, all the time
  helper_method :current_account, :admin?
  
  # See ActionController::RequestForgeryProtection for details
  # uncomment to use forgery protection
  # protect_from_forgery # :secret => '779a6e2f0fe7736f0a73da4a7d9f13d4'
  
  filter_parameter_logging :password, :creditcard

  protected
  
    def current_account
      @current_account ||= Account.find_by_full_domain(request.host)
      raise ActiveRecord::RecordNotFound unless @current_account
      @current_account
    end
    
    def events
      current_account.events
    end
    
    def admin?
      logged_in? && current_user.admin?
    end

    def redirect_to_back_or(other)
      redirect_to request.env["HTTP_REFERER"] || other
    end
    
    def order_by
      # If the model doesn't have a name attribute, this method should be overridden
      # This will determine the order of items that show up in the index.
      "name"
    end
end
