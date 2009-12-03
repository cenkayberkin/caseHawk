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
#  completed_by :integer(4)
#  account_id   :integer(4)
#  version      :integer(4)
#  deleted_at   :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class AllDayTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:all_day)
  end
  
  context "given a valid one-day event" do
    setup do
      @event = Factory.build(:all_day)
    end
    should "be able to be only one day" do
      assert_equal @event.starts_at.to_date, @event.ends_at.to_date
    end
    should_eventually "be able to span several days" do
      @event = Factory.create :starts_at => 2.days.ago,
                              :ends_at   => 3.days.from_now
      assert_valid @event
      assert_equal 2.days.ago.to_date,
                   @event.starts_at
      assert_equal 3.days.from_now.to_date,
                   @event.ends_at
    end
    should "not be completable" do
      assert !@event.completable?
    end
  end
end
