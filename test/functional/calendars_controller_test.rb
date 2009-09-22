require File.dirname(__FILE__) + '/../test_helper'

class CalendarsControllerTest < ActionController::TestCase
  context 'with a valid user,' do
    setup do
      @controller.stubs(:current_account).returns(@account = accounts(:localhost))
      @controller.stubs(:current_user).returns(@user = users(:quentin))
    end
    should 'have a logged in user' do 
      assert_equal users(:quentin), @controller.send(:current_user)
    end

    context 'GET to :show' do
      context "with no date given" do
        setup { get :show }
        should_respond_with :success
        should_render_template :show
        should_assign_to(:date) { Date.today }
      end
      context "with specific date given" do
        setup { get :show, :date => Date.yesterday.to_s }
        should_respond_with :success
        should_render_template :show
        should_assign_to(:date) { Date.yesterday }
      end
    end
  end
end
