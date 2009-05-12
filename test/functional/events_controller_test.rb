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

    context 'GET to new' do
      setup { get :new }

      should_respond_with :success
      should_render_template :new
      should_assign_to :event
    end

    context 'POST to create with valid parameters' do
      setup do
        post :create, :event => Factory.attributes_for(:event).merge(:type => 'AllDay')
      end
      should_change 'Event.count', :by => 1
      should_set_the_flash_to /created/i
      should_redirect_to 'events_path'
    end

    context 'GET to show for existing event' do
      setup do
        @event = Factory(:event)
        get :show, :id => @event.to_param
      end

      should_respond_with :success
      should_render_template :show
      should_assign_to :event
    end

    context 'GET to edit for existing event' do
      setup do
        @event = Factory(:event)
        get :edit, :id => @event.to_param
      end

      should_respond_with :success
      should_render_template :edit
      should_assign_to :event
    end

    context 'PUT to update for existing event' do
      setup do
        @event = Factory(:event)
        put :update, :id => @event.to_param,
          :event => Factory.attributes_for(:event)
      end

      should_set_the_flash_to /updated/i
      should_redirect_to 'events_path'
    end

    context 'given a event' do
      setup { @event = Factory(:event) }
      
      context 'DELETE to destroy' do
        setup { delete :destroy, :id => @event.to_param }

        should_change 'Event.count', :from => 1, :to => 0
        should_set_the_flash_to /deleted/i
        should_redirect_to 'events_path'
      end
    end
  end
end

