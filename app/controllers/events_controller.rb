class EventsController < ApplicationController

  before_filter :find_or_initialize

  def index
    @events = Event.find_by(params.slice(:start_date, :end_date, :tags, :id))
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

  def create
    @event.update_attributes(params[:event])
    flash[:success] = 'Event created.'
    redirect_to events_path
  end

  # render :show

  # render :edit

  def update
    @event.update_attributes(params[:event])
    flash[:success] = 'Event updated.'
    redirect_to events_path
  end

  def destroy
    @event.destroy
    flash[:success] = 'Event deleted.'
    redirect_to events_path
  end

  protected

    def new_event(atts = {})
      case params[:event] && params[:event][:type]
      when 'AllDay'       then AllDay.new(atts)
      when 'Appointment'  then Appointment.new(atts)
      when 'Deadline'     then Deadline.new(atts)
      when 'Task'         then Task.new(atts)
      else
        Event.new(atts)
      end
    end

    def find_or_initialize
      @event = params[:id] ?
                 Event.find(params[:id]) :
                 new_event(params[:event])
    end

end
