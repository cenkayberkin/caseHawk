class TagsController < ApplicationController

  def index
    @tags = Tag.search(params[:q]).limit(params[:limit] || 10)
    respond_to do |format|
      format.js do
        render :text => (@tags.map do |tag|
          "#{tag.name}|#{tag.id}"
        end.join("\n"))
      end
    end
  end

end
