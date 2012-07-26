class Tag < ActiveRecord::Base

  belongs_to :account
  has_many   :taggings
  
  validates_presence_of   :name
  validates_uniqueness_of :name, :scope => :account_id, :message => 'Tag name must be unique'

  scope :search, proc {|match|
    match.blank? ?
      {} :
      {:conditions => ["tags.name like ?", "%#{match}%"]}
  }
  scope :limit, proc {|n|
    {:limit => n}
  }

  scope :by_taggable_type, proc {|type|
    {:joins => :taggings,
     :select => "DISTINCT tags.*",
     :conditions => ["taggings.taggable_type = ?", type]
    }
  }

  scope :for_account, proc {|account|
    {:conditions => ["tags.account_id = ?", account.id]} if account
  }

end
