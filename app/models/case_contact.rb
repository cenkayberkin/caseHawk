class CaseContact < ActiveRecord::Base
  belongs_to :case
  belongs_to :contact

  validates_uniqueness_of :contact_id
end
