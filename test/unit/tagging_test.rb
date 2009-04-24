require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < ActiveSupport::TestCase

  should_validate_presence_of :tag
  should_validate_presence_of :taggable

  should "be valid with factory" do
    assert_valid Factory.build(:tagging)
  end

  context "tagging an Event" do
    setup do
      @tagging = Factory.create(:tagging)
    end
    should "have tag show up in Event#tags" do
      assert @tagging.taggable.tags.include?(@tagging.tag)
    end
    should "be invalid if the tagging is already applied" do
      assert !@tagging.taggable.taggings.build(:tag => @tagging.tag).valid?
    end
  end
  
end
