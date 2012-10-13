class Contact < ActiveRecord::Base
  attr_accessible :comment, :first_name, :last_name,
                  :phone_numbers_attributes,
                  :email_addresses_attributes

  belongs_to :user
  has_many   :phone_numbers
  has_many   :email_addresses

  validates :first_name, :presence => true
  validates :last_name,  :presence => true

  accepts_nested_attributes_for :phone_numbers
  accepts_nested_attributes_for :email_addresses

  def name
    "#{first_name} #{last_name}"
  end
end
