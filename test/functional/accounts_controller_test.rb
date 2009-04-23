require File.dirname(__FILE__) + '/../test_helper'
include ActiveMerchant::Billing

class AccountsControllerTest < ActionController::TestCase

  context 'accounts' do
    setup do
      @controller.stubs(:current_account).returns(@account = accounts(:localhost))
    end

    should 'create a new account' do
      @user = User.new(user_params = 
        { 'login' => 'foo', 'email' => 'foo@foo.com',
          'password' => 'password', 'password_confirmation' => 'password' })
      @account = Account.new(acct_params = 
        { 'name' => 'Bob', 'domain' => 'Bob' })
      User.expects(:new).with(user_params).returns(@user)
      Account.expects(:new).with(acct_params).returns(@account)
      @account.expects(:user=).with(@user)
      @account.expects(:save).returns(true)
    
      post :create, :account => acct_params, :user => user_params, :plan => subscription_plans(:basic).name
      assert_redirected_to(thanks_url)
      assert_equal @account.domain, flash[:domain]
    end
  
    should "list plans with the most expensive first" do
      get :plans
      assert_equal SubscriptionPlan.find(:all, :order => 'amount desc'), assigns(:plans)
    end
  
    context "loading the account creation page" do
      setup do
        @plan = subscription_plans(:basic)
        get :new, :plan => @plan.name
      end
    
      should "load the plan by name" do
        assert_response :ok, @response.body
        assert_equal @plan, assigns(:plan)
      end
    
      should "prep payment and address info" do
        assert assigns(:creditcard)
        assert assigns(:address)
      end
    end
  
    context 'updating an existing account' do
      should 'prevent a non-admin from updating' do
        @controller.stubs(:current_user).returns(users(:aaron))
        put :update, :account => { :name => 'Foo' }
        assert_redirected_to(new_session_url)
      end
    
      should 'allow an admin to update' do
        @controller.stubs(:current_user).returns(users(:quentin))
        @account.expects(:update_attributes).with('name' => 'Foo').returns(true)
        put :update, :account => { :name => 'Foo' }
        assert_redirected_to(account_url)
      end
    end
  
  
    context "updating billing info" do
      setup do
        @controller.stubs(:current_user).returns(@account.admin)
      end
    
      should "store the card when it and the address are valid" do
        CreditCard.stubs(:new).returns(@card = mock('CreditCard', :valid? => true, :first_name => 'Bo', :last_name => 'Peep'))
        SubscriptionAddress.stubs(:new).returns(@address = mock('SubscriptionAddress', :valid? => true, :to_activemerchant => 'foo'))
        @address.expects(:first_name=).with('Bo')
        @address.expects(:last_name=).with('Peep')
        @account.subscription.expects(:store_card).with(@card, :billing_address => 'foo', :ip => '0.0.0.0').returns(true)
        post :billing, :creditcard => {}, :address => {}      
      end
    
      context "with paypal" do
        should "redirect to paypal to start the process" do
          @account.subscription.expects(:start_paypal).with('http://test.host/account/paypal', 'http://test.host/account/billing').returns('http://foo')
          post :billing, :paypal => 'true'
          assert_redirected_to('http://foo')
        end
      
        should "go nowhere if the paypal token request fails" do
          @account.subscription.expects(:start_paypal).returns(nil)
          post :billing, :paypal => 'true'
          assert_template('accounts/billing')
        end
      
        should "set the subscription info from the paypal response" do
          @account.subscription.expects(:complete_paypal).with('bar').returns(true)
          get :paypal, :token => 'bar'
          assert_redirected_to(billing_account_url)
        end
      
        should "render the form when encountering problems with the paypal return" do
          @account.subscription.expects(:complete_paypal).with('bar').returns(false)
          get :paypal, :token => 'bar'
          assert_template('accounts/billing')
        end
      end
    end
  
    context "when canceling" do
      setup do
        @controller.stubs(:current_user).returns(users(:quentin))
      end
    
      should "not destroy the account without confirmation" do
        @account.expects(:destroy).never
        post :cancel
        assert_template('cancel')
      end
    
      should "destroy the account" do
        @account.expects(:destroy).returns(true)
        post :cancel, :confirm => 1
        assert_redirected_to('/account/canceled')
      end

      should "log out the user" do
        @account.stubs(:destroy).returns(true)
        @controller.expects(:current_user=).with(nil)
        post :cancel, :confirm => 1
      end
    end
  end
end