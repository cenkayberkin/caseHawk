class Case < ActiveRecord::Base
  attr_accessible :title, :case_type, :current_status,
                  :case_number_details, :general_case_details,
                  :referral, :referral_details, :legal_plan, :legal_plan_details,
                  :case_contacts_attributes, :contacts_attributes, :notes_attributes

  belongs_to :user

  has_many :case_contacts, :dependent => :destroy
  has_many :contacts, :through => :case_contacts
  has_many :notes

  accepts_nested_attributes_for :case_contacts, :allow_destroy => true,
                                :reject_if => proc { |a| a['contact_id'].blank? }
  accepts_nested_attributes_for :notes

  validates_uniqueness_of :title
end
