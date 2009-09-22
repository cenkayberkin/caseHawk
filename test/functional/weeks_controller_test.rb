require File.dirname(__FILE__) + '/../test_helper'

class WeeksControllerTest < ActionController::TestCase
  context "as user" do
    setup do
      @controller.stubs(:current_account).returns(@account = accounts(:localhost))
      @controller.stubs(:current_user).returns(@user = users(:quentin))
      setup {
        2.times { Factory.create :event,       :starts_at => Date.today }
        3.times { Factory.create :deadline,    :starts_at => Date.today }
        2.times { Factory.create :all_day,     :starts_at => Date.yesterday }
        1.times { Factory.create :appointment, :starts_at => Date.yesterday }
      }
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
        specified_date = 32.days.ago.to_date
        setup { get :show, :id => specified_date.to_s }
        should_respond_with :success
        should_render_template :show
        should_assign_to(:date) { specified_date.beginning_of_week.to_date }
        should "find the week's events" do
          assert_equal Event.week_of(specified_date),
                       assigns(:events)
        end
      end

      context "with specified date param" do
        specified_date = 4.days.from_now.to_date
        setup { get :show, :id => specified_date.to_s }
        should_respond_with :success
        should_render_template :show
        should_assign_to(:date) { specified_date.beginning_of_week.to_date }
        should "find the week's events" do
          assert_equal Event.week_of(specified_date),
                       assigns(:events)
        end
      end
    end
  end
end

