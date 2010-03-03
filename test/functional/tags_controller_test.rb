require File.dirname(__FILE__) + '/../test_helper'

class TagsControllerTest < ActionController::TestCase

  context "on GET to :index" do
    setup {
      @controller.stubs(:current_account).returns(@account = Factory(:account))
      @controller.stubs(:current_user).returns(@user = Factory(:user, :account => @account))

      3.times do |n|
        Factory :tag, :name => ["brown #{n}", "orange #{n}"][n % 2], :account => Factory.create(:account)
      end
      12.times do |n|
        Factory :tag, :name => ["green #{n}", "blue #{n}"][n % 2], :account => @account
      end
    }
    context "with no params" do
      setup { get :index }
      should_respond_with :success
      should_respond_with_content_type :js
      should "limit response to 10 records" do
        assert_equal 10, assigns(:tags).length
      end
      should "return the first ten records" do
        assert_equal @account.tags.find(:all, :limit => 10),
                     assigns(:tags)
      end
      should "have only tags from the current account" do
        assigns(:tags).each do |tag|
          assert_equal @account, tag.account
        end
      end
    end
    context "with q param" do
      setup { get :index, :q => 'green' }
      should "return only records containing 'green' in their name" do
        assert_equal @account.tags.find(:all,
                                        :conditions => ["name like ?",
                                                        "%green%"]),
                     assigns(:tags)
      end
    end
    context "with limit param" do
      setup { get :index, :limit => '2' }
      should "return only the number of records specified" do
        assert_equal @account.tags.find(:all, :limit => 2), assigns(:tags)
      end
    end
  end
end

