class CalendarsController < ApplicationController

  def show
    @date = Date.today
    @events = Event.today || []
    respond_to do |format|
      format.html do
        render :action => :show
      end
      format.js do
        render :json => @events.to_json
      end
    end
  end
end