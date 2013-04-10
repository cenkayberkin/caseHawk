class Note < ActiveRecord::Base
  attr_accessible :case_id, :notes, :title

  belongs_to :case

  validates_uniqueness_of :title
end
