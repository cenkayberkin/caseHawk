class Address < ActiveRecord::Base
  attr_accessible :label, :street, :unit, :city, :state, :postal_code

  belongs_to :addressable, :polymorphic => true
end
