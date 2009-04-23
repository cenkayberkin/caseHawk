# == Schema Information
#
# Table name: locations
#
#  id         :integer(4)      not null, primary key
#  event_id   :integer(4)
#  name       :string(50)
#  created_at :datetime
#  updated_at :datetime
#

class Location < ActiveRecord::Base

  has_many :addresses, :as => :addressable
  has_many :events
  
  
end
