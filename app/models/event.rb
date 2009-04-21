# == Schema Information
#
# Table name: events
#
#  id         :integer(4)      not null, primary key
#  creator_id :integer(4)      not null
#  owner_id   :integer(4)
#  type       :string(255)     not null
#  name       :string(255)     not null
#  start_date :date
#  start_time :time
#  end_date   :date
#  end_time   :time
#  remind     :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

class Event < ActiveRecord::Base
  
  belongs_to :location
  
  validates_presence_of :name
  validates_presence_of :creator_id
  validates_presence_of :kind

  
end
