class CalendarsController < ApplicationController

  def index
    render :json => Event.all.to_json
  end

  def today
    render :json => Event.today.to_json
  end
end
