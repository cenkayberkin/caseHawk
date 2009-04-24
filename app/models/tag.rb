class Tag < ActiveRecord::Base

  validates_presence_of   :name
  validates_uniqueness_of :name, :message => 'Tag name must be unique'
end
