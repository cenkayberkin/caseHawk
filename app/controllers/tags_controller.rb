class TagsController < ApplicationController

  def index
    @tags = Tag.search(params[:q]).limit(params[:limit] || 10)
    respond_to do |format|
      format.json do
        render :json => @tags
      end
    end
  end

end
