require File.dirname(__FILE__) + '/../test_helper'

class RecentTagTest < ActiveSupport::TestCase
  should "be valid with factory" do
    assert_valid Factory.build(:recent_tag)
  end
end
