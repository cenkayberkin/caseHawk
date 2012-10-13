class EmailAddress < ActiveRecord::Base
  attr_accessible :email, :label

  validates :email, :presence => true
  validates :label, :presence => true

  belongs_to :contact
end
