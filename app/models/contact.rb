class Contact < ActiveRecord::Base
  attr_accessible :comment, :first_name, :last_name

  belongs_to :user

  def name
    "#{first_name} #{last_name}"
  end
end
