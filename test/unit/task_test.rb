# == Schema Information
#
# Table name: events
#
#  id          :integer(4)      not null, primary key
#  creator_id  :integer(4)      not null
#  owner_id    :integer(4)
#  location_id :integer(4)
#  type        :string(255)     not null
#  name        :string(255)     not null
#  start_date  :date
#  start_time  :time
#  end_date    :date
#  end_time    :time
#  remind      :boolean(1)
#  created_at  :datetime
#  updated_at  :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:task)
  end
 
  context "given a valid task" do
    setup do
      @event = Factory(:task)
    end
    should "have a no end date" do
      assert_nil @event.ends_at
    end
    should "be completable" do
      @event.completable?
    end
  end
end
