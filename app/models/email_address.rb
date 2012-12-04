class EmailAddress < ActiveRecord::Base
  attr_accessible :email, :label

  belongs_to :contact
end
