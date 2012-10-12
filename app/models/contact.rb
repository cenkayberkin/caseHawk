class Contact < ActiveRecord::Base
  attr_accessible :comment, :first_name, :last_name,
                  :phone_numbers_attributes

  belongs_to :user
  has_many   :phone_numbers

  accepts_nested_attributes_for :phone_numbers

  def name
    "#{first_name} #{last_name}"
  end
end
