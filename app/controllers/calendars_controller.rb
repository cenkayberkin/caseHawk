class CalendarsController < ApplicationController

  def show
    @start_date = params[:start_date] ?
                    Date.parse(params[:start_date]) :
                    Date.today.beginning_of_week
    @end_date =   params[:end_date] ?
                    Date.parse(params[:end_date]) :
                    Date.today.end_of_week
    respond_to do |format|
      format.js do
        render :json => Event.all.to_json
      end
      format.html
      format.ical
    end
  end

  def today
    @date = Date.today
    respond_to do |format|
      format.js do
        render :json => Event.today.to_json
      end
      format.html
      format.ical
    end
  end
end