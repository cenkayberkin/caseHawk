class RecentTag < ActiveRecord::Base

  belongs_to :user
  belongs_to :tag

  scope :ordered, "updated_at DESC"
  
  scope :of_user, proc { |user|
    { :conditions => ["user_id = ? ", user.id] }
  }
  
  scope :limit, proc { |n|
    { :limit => n }
  }

end
