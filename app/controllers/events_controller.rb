class EventsController < ApplicationController
  include ModelControllerMethods

  before_filter :find_or_initialize

  def index
    @events = Event.find_by(params.slice(:start_date, :end_date, :tags, :id, :week))
    respond_to do |format|
      format.html
      format.js do
        render :json => @events.to_json
      end
      format.ical
    end
  end

  def new
    @event = Event.new
  end

  # render :show

  # render :edit

  protected

    def new_event(atts = {})
      
      event = case params[:event] && params[:event][:type]
                when 'AllDay'       then AllDay.new(atts)
                when 'Appointment'  then Appointment.new(atts)
                when 'Deadline'     then Deadline.new(atts)
                when 'Task'         then Task.new(atts)
                else
                  Event.new(atts)
                end
      event.creator = current_user
    end

    def find_or_initialize
      @obj = params[:id] ?
                 Event.find(params[:id]) :
                 new_event(params[:event])
    end

end
