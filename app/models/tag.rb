# == Schema Information
# Schema version: 20090505212954
#
# Table name: tags
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Tag < ActiveRecord::Base

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
