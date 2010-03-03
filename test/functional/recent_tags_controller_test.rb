require File.dirname(__FILE__) + '/../test_helper'

class RecentTagsControllerTest < ActionController::TestCase
  context "on GET to :index" do
    setup {
      @controller.stubs(:current_account).returns(@account = accounts(:localhost))
      @controller.stubs(:current_user).returns(@user = users(:quentin))
      25.times do |n|
        Factory.create :recent_tag, :updated_at => n.days.ago, :user => @user
      end
    }
    context "with no params" do
      setup { xhr :get, :index }
      should_respond_with :success
      should_respond_with_content_type :js
      should "return the most recent ten records" do
        assert_equal @user.recent_tags.ordered.find(:all, :limit => 10), assigns(:recent_tags)
      end
      should "limit response to 10 records" do
        assert_equal 10, assigns(:recent_tags).length
      end
      should "have only tags from the current user" do
        assigns(:recent_tags).each do |rt|
          assert_equal @user, rt.user
        end
      end
    end
  end
end
