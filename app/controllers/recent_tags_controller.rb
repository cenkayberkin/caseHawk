class RecentTagsController < ApplicationController
  include ModelControllerMethods

  has_scope :limit, :default => 10

  skip_before_filter :load_object, :only => :update

  def update
    tag = tags.find_by_name(params[:id])

    @recent_tag = current_user.recent_tags.find_or_initialize_by_tag_id(tag.id)
    @recent_tag.count = @recent_tag.count.to_i + 1
    @recent_tag.save

    respond_to do |format|
      format.js { render :json => @recent_tag }
    end
  end


  protected
    def scoper
      apply_scopes(RecentTag).of_user(current_user)
    end

    def order_by
      "updated_at DESC"
    end
    
end
