require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < ActiveSupport::TestCase

  should_require_attributes :tag
  should_require_attributes :taggable
  should_require_attributes :creator

  should "be valid with factory" do
    assert_valid Factory.build(:tagging)
  end

  context "tagging an Event" do
    setup do
      @tagging = Factory(:tagging)
    end

    should "description" do
      
    end
  end
  
end
