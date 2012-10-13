class Address < ActiveRecord::Base
  attr_accessible :label, :street, :unit, :city, :state, :postal_code

  validates :label,       :presence => true
  validates :street,      :presence => true
  validates :unit,        :presence => true
  validates :city,        :presence => true
  validates :state,       :presence => true
  validates :postal_code, :presence => true

  belongs_to :addressable, :polymorphic => true
end
