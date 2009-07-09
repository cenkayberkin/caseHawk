class EventsController < ApplicationController
  include ModelControllerMethods

  before_filter :find_or_initialize, :except => :index

  def index
    @events = Event.find_by(params.slice(:starts_at, :ends_at, :tags, :id, :week))
    respond_to do |format|
      format.html
      format.js do
        render :json => @events.to_json
      end
      format.ical
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.js do
        render :json => @events.to_json
      end
      format.ical
    end
  end

  def create
    update
  end

  def update
    @event.attributes = params[:event]
    if params[:event] && !params[:event][:completed].blank?
      @event.completed_by = current_user
    end
    @saved = @event.save
    respond_to do |format|
      format.html {
        @saved ?
          flash[:success] = "The event has been saved" :
          flash[:error] = "There was an error saving that event"
        redirect_to_back_or calendar_path(:date => @event.starts_at.to_date.to_s)
      }
      format.js {
        render :json => @event
      }
    end
  end

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
      event
    end

    def find_or_initialize
      @event = @obj = params[:id] ?
                 Event.find(params[:id]) :
                 new_event(params[:event])
    end

end
