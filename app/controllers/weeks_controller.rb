class WeeksController < ApplicationController

  before_filter :find_date

  def index
    redirect_to calendar_path
  end

  def show
    @events = events.ordered.week_of(@date).find(:all, :include => :creator)
    render :action => 'show', :layout => false
  end

  protected

  def find_date
    param = params[:id] || params[:date]
    @date = (param ?
      Date.parse(param) : Date.today).beginning_of_week.to_date
  end

end
