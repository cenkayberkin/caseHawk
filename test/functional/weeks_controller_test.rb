require File.dirname(__FILE__) + '/../test_helper'

class WeeksControllerTest < ActionController::TestCase
  context "as user" do
    setup do
      @controller.stubs(:current_account).returns(@account = accounts(:localhost))
      @controller.stubs(:current_user).returns(@user = users(:quentin))
    end
    should 'have a logged in user' do
      assert_equal users(:quentin), @controller.send(:current_user)
    end

    context "on GET to :index" do
      context "with no id param" do
        setup { get :index }
        should_respond_with :redirect
        should_redirect_to("show action") { week_path(Date.today.to_s) }
      end
    end

    context "on GET to :show" do
      context "with specified id param" do
        setup { get :show, :id => 32.days.ago.to_date.to_s }
        should_respond_with :success
        should_render_template :show
        p 32.days.ago.beginning_of_week.to_date
        should_assign_to(:date) { 32.days.ago.to_date.beginning_of_week.to_date }
      end

      context "with specified date param" do
        setup { get :show, :id => 4.days.from_now.to_date.to_s }
        should_respond_with :success
        should_render_template :show
        should_assign_to(:date) { 4.days.from_now.to_date.beginning_of_week.to_date }
      end
    end
  end
end

