# == Schema Information
#
# Table name: addresses
#
#  id               :integer(4)      not null, primary key
#  label            :string(255)
#  addressable_id   :integer(4)
#  addressable_type :string(255)
#  street           :string(255)
#  unit             :string(255)
#  city             :string(50)
#  postal_code      :string(10)
#  state            :string(50)
#  created_at       :datetime
#  updated_at       :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class AddressTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:address)
  end
 
end
