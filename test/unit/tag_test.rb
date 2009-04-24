require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase

  should "be valid with factory" do
    assert_valid Factory.build(:tag)
  end

  context "with some tags already created" do
    setup { Factory(:tag); Factory(:tag) }
    should_validate_presence_of   :name
    should_validate_uniqueness_of :name,
                                  :message => 'must be unique'
  end
end
