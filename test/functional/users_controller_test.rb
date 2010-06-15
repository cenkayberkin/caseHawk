require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase

  context "test" do
    setup do
      @controller.stubs(:current_account).returns(@account = accounts(:localhost))
      @user = @account.users.first
    end
  
    context "with normal users" do
      setup do
        @controller.stubs(:current_user).returns(users(:aaron))
      end
      context "on GET to :index" do
        setup { get :index }
        should_render_template :index
        should "show users" do
          assert_equal Set.new(@account.users), Set.new(assigns(:users))
        end
      end
    
      context "on GET to :new" do
        setup { get :new }
        should_redirect_to "sign in" do
          new_session_url
        end
      end

      context "on POST to :create" do
        setup { post :create, :user => { :name => 'bob' } }
        should_redirect_to "sign in" do
          new_session_url
        end
      end
    
      context "on GET to :edit" do
        setup { get :edit, :id => @user.id }
        should_redirect_to "sign in" do
          new_session_url
        end
      end
    
      context "on PUT to :update" do
        setup {
          put :update, :id => @user.id, :user => { :name => 'bob' }
        }
        should_redirect_to "sign in" do
          new_session_url
        end
      end
    end
  
    context "with admin users" do
      setup do
        @controller.stubs(:current_user).returns(users(:quentin))
        @account.stubs(:reached_user_limit?).returns(false)
      end

      should "allow viewing the index" do
        get :index
        assert_template :index
        assert_equal Set.new(@account.users), Set.new(assigns(:users))
      end

      should "allow adding users" do
        get :new
        assert_template :new
        assert assigns(:user).new_record?
      end

      should "allow creating users" do
        post :create, :user => valid_user
        assert !assigns(:user).new_record?
        assert_redirected_to users_url
      end
    
      should "allow editing users" do
        get :edit, :id => @user.id
        assert_equal @user, assigns(:user)
        assert_template :edit
      end
    
      should "allow updating users" do
        put :update, :id => @user.id, :user => valid_user
        assert_redirected_to users_url
      end

      should "prevent creating users when the user limit has been reached" do
        @account.expects(:reached_user_limit?).returns(true)
        @user.expects(:save).never
        post :create, :user => valid_user
        assert_redirected_to new_user_url
      end
    end
  end
end