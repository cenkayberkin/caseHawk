class TagsController < ApplicationController

  # see the has_scope gem for more info
  has_scope :limit, :default => 10
  has_scope :search, :as => :q
  has_scope :by_taggable_type
  has_scope :account, :default => 'always' do |controller, scope|
    scope.for_account(controller.current_account)
  end

  def index
    @tags = apply_scopes(Tag).all
    respond_to do |format|
      format.js do
        render :text => (@tags.map do |tag|
          "#{tag.name}|#{tag.id}"
        end.join("\n"))
      end
    end
  end
end
