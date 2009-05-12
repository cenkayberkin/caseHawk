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
      setup do
        get :show
      end
      should_respond_with :success
      should_render_template :show
    end

    context 'GET to :today' do
      setup do
        get :today
      end
      should_respond_with :success
      should_render_template :show
    end
  end
end
