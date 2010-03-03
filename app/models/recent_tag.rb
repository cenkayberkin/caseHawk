class RecentTag < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag

  named_scope :ordered, "updated_at DESC"
  
  named_scope :of_user, proc {|user|
    { :conditions => ["user_id = ? ", user.id] }
  }
  
  named_scope :limit, proc {|n|
    {:limit => n}
  }
  
end
