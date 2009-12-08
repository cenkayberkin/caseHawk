class TagsController < ApplicationController

  def index
    @tags = tags.search(params[:q]).limit(params[:limit] || 10)
    respond_to do |format|
      format.js do
        render :text => (@tags.map do |tag|
          "#{tag.name}|#{tag.id}"
        end.join("\n"))
      end
    end
  end

  def tags
    current_account.tags
  end

end
