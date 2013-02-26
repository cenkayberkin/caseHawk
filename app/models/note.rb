class Note < ActiveRecord::Base
  attr_accessible :case_id, :notes, :title

  belongs_to :case
end
