# == Schema Information
#
# Table name: events
#
#  id           :integer(4)      not null, primary key
#  account_id   :integer(4)      not null
#  creator_id   :integer(4)      not null
#  owner_id     :integer(4)
#  type         :string(255)     not null
#  name         :string(255)     not null
#  remind       :boolean(1)
#  created_at   :datetime
#  updated_at   :datetime
#  completed_at :datetime
#  starts_at    :datetime
#  ends_at      :datetime
#  location_id  :integer(4)
#  completed_by :integer(4)
#  version      :integer(4)
#  deleted_at   :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class AppointmentTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:appointment)
  end
 
  context "given a valid appointment" do
    setup do
      @event = Factory(:appointment)
    end
    should "not be completable" do
      assert !@event.completable?
    end
  end
end
