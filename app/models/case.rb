class Case < ActiveRecord::Base
  attr_accessible :title, :current_status,
                  :case_number_details, :general_case_details,
                  :referral, :referral_details, :legal_plan, :legal_plan_details,
                  :case_contacts_attributes, :contacts_attributes

  belongs_to :user

  has_many :case_contacts
  has_many :contacts, :through => :case_contacts

  accepts_nested_attributes_for :case_contacts
  accepts_nested_attributes_for :contacts
end
