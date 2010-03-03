class RecentTagsController < ApplicationController
  include ModelControllerMethods

  has_scope :limit, :default => 10

  protected
    def scoper
      apply_scopes(RecentTag).of_user(current_user)
    end
    
    def order_by
      "updated_at DESC"
    end
    
end
