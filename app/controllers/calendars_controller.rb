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
    logger.info("Trying to parse: #{params[:date]}")
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
  end
  
  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    respond_to do |format|
      format.html do 
        redirect_to params.merge!(:action => :show)
      end
    end
  end
end