class Contact < ActiveRecord::Base
  attr_accessible :comment, :first_name, :last_name

  belongs_to :user
end
