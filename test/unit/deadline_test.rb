# == Schema Information
#
# Table name: events
#
#  id           :integer(4)      not null, primary key
#  creator_id   :integer(4)      not null
#  owner_id     :integer(4)
#  location_id  :integer(4)
#  type         :string(255)     not null
#  name         :string(255)     not null
#  remind       :boolean(1)
#  created_at   :datetime
#  updated_at   :datetime
#  completed_at :datetime
#  starts_at    :datetime
#  ends_at      :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class DeadlineTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.create :deadline
  end
  
  context "given a valid deadline" do
    setup do
      @event = Factory.create :deadline
    end
    should "be valid" do
      assert @event.valid?
    end
    should "be completable" do
      assert @event.completable?
    end
  end
end
