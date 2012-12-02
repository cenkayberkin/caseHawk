class Case < ActiveRecord::Base
  belongs_to :user
  
  has_many :case_contacts
  has_many :contacts, :through => :case_contacts
end