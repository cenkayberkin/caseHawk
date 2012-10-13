class PhoneNumber < ActiveRecord::Base
  attr_accessible :label, :number

  validates :label,  :presence => true
  validates :number, :presence => true

  belongs_to :contact
end
