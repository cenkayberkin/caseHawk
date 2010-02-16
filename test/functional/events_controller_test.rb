require File.dirname(__FILE__) + '/../test_helper'

class EventsControllerTest < ActionController::TestCase
  
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

    context 'POST to create with valid parameters' do
      setup do
        post :create, :event => Factory.attributes_for(:event).merge(:type => 'AllDay')
      end
      should_change 'Event.count', :by => 1
      should_set_the_flash_to /saved/i
      should_redirect_to("single day") { day_calendar_path(:date => assigns(:event).starts_at.to_date.to_s) }
    end

    context 'GET to show for existing event' do
      setup do
        @event = Factory(:event, :account => @account)
        get :show, :id => @event.to_param
      end

      should_respond_with :success
      should_render_template :show
      should_assign_to :event
    end

    context 'GET to edit for existing event' do
      setup do
        @event = Factory(:event, :account => @account)
        get :edit, :id => @event.to_param
      end

      should_respond_with :success
      should_render_template :edit
      should_assign_to :event
    end

    # UPDATE

    context 'PUT to update' do
      setup { @event = Factory.create(:task, :account => @account) }
      context 'for existing event' do
        setup {
          put :update, :id => @event.to_param,
                       :event => Factory.attributes_for(:event)
        }
        should_change "@event.reload.attributes"
        should_not_change "Event.count"
        should_set_the_flash_to /saved/i
        should_redirect_to("single day") {day_calendar_path(:date => @event.starts_at.to_date.to_s) }
      end
      context "via ajax to complete event" do
        setup {
          xhr :put,
              :update,
              :id => @event.to_param,
              :event => {:completed => 'true'}
          @event.reload
        }
        should_respond_with :ok
        should_change "@event.reload.completed_at"
        should "set event completed at to now" do
          assert @event.completed_at > 2.seconds.ago
          assert @event.completed_at < 1.second.from_now
        end
      end
      context "via html to complete event" do
        setup {
          put :update,
              :id => @event.to_param,
              :event => {:completed => 'true'}
          @event.reload
        }
        should_respond_with :redirect
        should_change "@event.reload.completed_at"
        should "set event completed at to now" do
          assert @event.completed_at > 2.seconds.ago
          assert @event.completed_at < 1.second.from_now
        end
      end
    end

    context 'given a event' do
      setup { @event = Factory(:event, :account => @account) }
      context 'DELETE to destroy' do
        context 'an event via http' do
          setup { delete :destroy, :id => @event.to_param }

          should_change 'Event.count', :from => 1, :to => 0
          should_set_the_flash_to /deleted/i
          should_redirect_to("index") { events_path }
        end
        context 'an event via ajax' do
          setup{
            xhr :delete,
                :destroy,
                :id => @event.to_param
          }
          should_respond_with :ok
          should_change 'Event.count', :from => 1, :to => 0
          should_respond_with_content_type :js
        end
      end
    end
  end
end

