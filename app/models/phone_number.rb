class PhoneNumber < ActiveRecord::Base
  attr_accessible :label, :number

  belongs_to :contact
end
