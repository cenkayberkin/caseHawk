class EventsController < ApplicationController
  include ModelControllerMethods

  before_filter :find_or_initialize, :except => :index

  def index
    @events = events.find_by(params.slice(:starts_at, :ends_at, :tags, :id, :week))
    respond_to do |format|
      format.html
      format.js do
        render :json => @events.to_json
      end
      format.xml do
        render :xml => @events.to_xml
      end
      format.ical
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.js do
        render :json => @event.to_json
      end
      format.xml do
        render :xml => @event.to_xml
      end
      format.ical
    end
  end

  def create
    update
  end

  def update
    # Make sure the event stays within this account
    params[:event][:account_id] = current_account.id
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
        redirect_to_back_or day_calendar_path(:date => @event.starts_at.to_date.to_s)
      }
      format.js {
        render :json => @event
      }
      format.xml {
        render :xml => @event.to_xml
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
                  events.new(atts)
                end
      event.creator = current_user
      event
    end

    def find_or_initialize
      @event = @obj = params[:id] ?
                 events.find_by_id(params[:id]) :
                 new_event(params[:event])
    end

end
