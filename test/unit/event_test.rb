# == Schema Information
#
# Table name: events
#
#  id         :integer(4)      not null, primary key
#  creator_id :integer(4)      not null
#  owner_id   :integer(4)
#  type       :string(255)     not null
#  name       :string(255)     not null
#  start_date :date
#  start_time :time
#  end_date   :date
#  end_time   :time
#  remind     :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase

  should_require_attributes :name
  should_require_attributes :creator_id
  should_require_attributes :kind
  
  context "creator" do
    setup { @event = Factory(:event) }
    should_eventually "be a user" do
    end
  end
  
  context "owner" do
    setup { @event = Factory(:event) }
    should_eventually "be a user" do
    end
  end

  context "Appointment" do
    setup do
      @event = Factory(:appointment)
    end
    should_eventually "have start date" do
    end
    should_eventually "have end date" do
    end
    should_eventually "have start time" do
    end
    should_eventually "have end time" do
    end
  end

  context "Deadline" do
    setup do
      @event = Factory(:deadline)
    end
    should_eventually "have start date" do
    end
    should_eventually "have no end date" do
    end
    should_eventually "have start time" do
    end
    should_eventually "have no end time" do
    end
    should_eventually "be completable" do
    end
  end
  
  context "Task" do
    setup do
      @event = Factory(:task)
    end
    should_eventually "have a start date" do
    end
    should_eventually "have no end date" do
    end
    should_eventually "have no start time" do
    end
    should_eventually "have no end time" do
    end
    should_eventually "be completable" do
    end
  end
  
  context "AllDay" do
    setup do
      @event = Factory(:task)
    end
    should_eventually "have a start date" do
    end
    should_eventually "have an end date" do
    end
    should_eventually "have no start time" do
    end
    should_eventually "have no end time" do
    end
    should_eventually "be able to be only one day" do
    end
    should_eventually "be able to span several days" do
    end
  end
end