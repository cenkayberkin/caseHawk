# == Schema Information
#
# Table name: locations
#
#  id         :integer(4)      not null, primary key
#  event_id   :integer(4)
#  name       :string(50)
#  created_at :datetime
#  updated_at :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class LocationTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:location)
  end
 
end
