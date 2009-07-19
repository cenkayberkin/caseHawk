class CalendarsController < ApplicationController

  def show
    @date = params[:date] ?
              Date.parse(params[:date]) : Date.today
    @events = events.day(@date).find(:all, :include => :creator) || []
    respond_to do |format|
      format.html do
        render :action => :show
      end
      format.js do
        render :json => @events.to_json
      end
    end
  end
  
  def weeks
    @date = params[:date] ?
              Date.parse(params[:date]) : Date.today
    @events = events.ordered.week_of(@date).find(:all, :include => :creator) +
              events.ordered.week_of(@date - 1.week).find(:all, :include => :creator) +
              events.ordered.week_of(@date + 1.week).find(:all, :include => :creator)
    respond_to do |format|
      format.html
      format.js do
        render :json => @events.to_json
      end
    end
  end
  
  def index
    respond_to do |format|
      format.html do 
        redirect_to :action => :weeks
      end
    end
  end
end