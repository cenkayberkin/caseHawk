class CalendarsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_date

  def day
    @events = events.day(@date).find(:all, :include => :creator) || []
    respond_to do |format|
      format.html 
      format.js do
        render :json => @events.to_json
      end
    end
  end
  
  def show
  end
  
  def index
    respond_to do |format|
      format.html do 
        redirect_to params.merge!(:action => :show)
      end
    end
  end
  
  protected

  def find_date
    begin
      @date = (params[:date].blank? ? Date.today : Date.parse(params[:date]))
    rescue 
      @date = Date.today
    end
  end
  
end
