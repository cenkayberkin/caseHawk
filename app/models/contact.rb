class Contact < ActiveRecord::Base
  attr_accessible :comment, :first_name, :last_name,
                  :phone_numbers_attributes,
                  :addresses_attributes,
                  :email_addresses_attributes

  belongs_to :user
  has_many   :case_contacts
  has_many   :phone_numbers
  has_many   :email_addresses
  has_many   :addresses, :as => :addressable
  has_many   :cases, :through => :case_contacts

  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true
  accepts_nested_attributes_for :addresses, :allow_destroy => true
  accepts_nested_attributes_for :email_addresses, :allow_destroy => true

  def name
    "#{first_name} #{last_name}"
  end

  def name_and_email
    if main_email_address.present?
      "#{name} (#{main_email_address})"
    else
      name
    end
  end

  def main_email_address
    email_addresses.where(:label => 'Main').first
  end

  def home_phone_number
    phone_numbers.where(:label => 'Home').first
  end
end
