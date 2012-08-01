class EventsController < ApplicationController
  include ModelControllerMethods

  skip_before_filter :build_object
  before_filter :authenticate_user!
  before_filter :find_or_initialize, :except => :index
  before_filter :mark_modified_by_current_user, :only => [:create, :update]

  def index
    @events = events.ordered.find_by(params.slice(:starts_at, :ends_at, :tags, :id, :week))
    respond_to do |format|
      format.html
      format.js do
        render :json => (@events.map do |event|
          render_to_string(:partial => 'events/event', :object => event)
        end)
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        render :action => :show, :layout => false
      end
    end
  end

  def create
    update
  end

  def update
    # Make sure the event stays within this account
    params[:event][:account_id] = current_account.id
    @event.attributes = params[:event].except(:type)
    if params[:event] && !params[:event][:completed].blank?
      @event.completed_by = current_user
    end
    @event.creator = current_user # Flag this revision as being created by this user
    @event.save
    
    respond_to do |format|
      format.js do
        render :json => {:record => @event,
                         :html   => render_to_string(:partial => 'events/event', :object => @event)
                        }
      end
    end
  end

  def destroy
    @event.update_attribute :modified_by_id, current_user.id
    super
  end
  
  protected
    def new_event(atts = {})

      event = case params[:event] && params[:event][:type]
                when 'AllDay'       then AllDay.new(atts)
                when 'Appointment'  then Appointment.new(atts.except(:type))
                when 'CourtDate'    then CourtDate.new(atts.except(:type))
                when 'Deadline'     then Deadline.new(atts.except(:type))
                when 'Task'         then Task.new(atts.except(:type))
                else
                  events.new(atts)
                end

      event.creator = current_user

      event
    end

    def mark_modified_by_current_user
      @event.modified_by_id = current_user.id
    end

    def find_or_initialize
      @event = @obj = params[:id] ?
                 events.find_by_id(params[:id]) :
                 new_event(params[:event])
    end

end
