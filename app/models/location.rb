class Location < ActiveRecord::Base

  has_many :addresses, :as => :addressable
  has_many :events
  
end
