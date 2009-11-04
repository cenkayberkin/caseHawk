class TaggingsController < ApplicationController

  before_filter :find_parent, :only => :create

  include ModelControllerMethods

  def create
    @parent.taggings.create(:tag => Tag.find_or_create_by_name(params[:tag_name]))
  end


  protected
  
    def find_parent
      @parent ||= if params[:event_id]
        Event.find(params[:event_id])
      elsif params[:user_id]
        User.find(params[:user_id])
      end
    end

end
