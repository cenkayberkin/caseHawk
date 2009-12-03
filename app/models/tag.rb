# == Schema Information
#
# Table name: tags
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  account_id :integer(4)
#

class Tag < ActiveRecord::Base

  belongs_to :account

  validates_presence_of   :name
  validates_uniqueness_of :name, :message => 'Tag name must be unique'

  named_scope :search, proc {|match|
    match.blank? ?
      {} :
      {:conditions => ["tags.name like ?", "%#{match}%"]}
  }
  named_scope :limit, proc {|n|
    {:limit => n}
  }
end
