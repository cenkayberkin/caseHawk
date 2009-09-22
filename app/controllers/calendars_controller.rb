class CalendarsController < ApplicationController

  def day
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @events = events.day(@date).find(:all, :include => :creator) || []
    respond_to do |format|
      format.html 
      format.js do
        render :json => @events.to_json
      end
    end
  end
  
  def show
    @date = params[:date] ?
              Date.parse(params[:date]) : Date.today
  end
  
  def index
    respond_to do |format|
      format.html do 
        redirect_to :action => :show
      end
    end
  end
end