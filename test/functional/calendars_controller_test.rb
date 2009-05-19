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
      setup {
        2.times { Factory.create :event,       :start_date => Date.today }
        9.times { Factory.create :deadline,    :start_date => Date.today }
        4.times { Factory.create :all_day,     :start_date => Date.yesterday }
        3.times { Factory.create :appointment, :start_date => Date.yesterday }
      }
      context "with no date given" do
        setup { get :show }
        should_respond_with :success
        should_render_template :show
        should "find today's events" do
          assert_equal Event.today.find(:all),
                       assigns(:events)
        end
      end
      context "with specific date given" do
        setup { get :show, :date => Date.yesterday.to_s }
        should_respond_with :success
        should_render_template :show
        should "find specific day's events" do
          assert_equal Event.day(Date.yesterday).find(:all),
                       assigns(:events)
        end
      end
    end
  end
end