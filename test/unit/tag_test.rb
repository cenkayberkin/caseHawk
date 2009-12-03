# == Schema Information
#
# Table name: tags
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  account_id :integer(4)
#

require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase

  should_have_named_scope 'limit(1)', :limit => 1
  should_have_named_scope 'limit(4)', :limit => 4
  should_have_named_scope 'search("green")', :conditions => [
                                            "tags.name like ?",
                                            '%green%'
                                           ]

  should "be valid with factory" do
    assert_valid Factory.build(:tag)
  end

  context "with some tags already created" do
    setup { Factory(:tag); Factory(:tag) }
    should_validate_presence_of   :name
    should_validate_uniqueness_of :name,
                                  :message => /must be unique/
  end
end
