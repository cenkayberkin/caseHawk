require 'test_helper'

class CalendarsControllerTest < ActionController::TestCase
  context 'with a valid user,' do
    setup do
      @controller.stubs(:current_account).returns(@account = accounts(:localhost))
      @controller.stubs(:current_user).returns(@user = users(:quentin))
    end
    should 'have a logged in user' do 
      assert_equal users(:quentin), @controller.send(:current_user)
    end
    
    context 'GET to index' do
      setup do
        get :index
      end
      should_respond_with :success
      should_render_template :index
    end
    
    context 'GET to show for user calendar' do
      setup do
        @event = Factory(:event)
        get :show, :id => @event.to_param
      end

      should_respond_with :success
      should_render_template :show
      should_assign_to :event, :equals => '@event'
    end

  end
end
