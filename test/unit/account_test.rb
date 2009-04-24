# == Schema Information
#
# Table name: accounts
#
#  id                       :integer(4)      not null, primary key
#  name                     :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  full_domain              :string(255)
#  deleted_at               :datetime
#  subscription_discount_id :integer(8)
#

require File.dirname(__FILE__) + '/../test_helper'
require 'ostruct'
include ActiveMerchant::Billing

class AccountTest < ActiveSupport::TestCase

  should "be valid with factory" do
    Factory(:account)
    assert Factory.build(:account).save!, Factory.build(:account).errors.inspect
  end

  context "Account" do
    setup do
      @account = accounts(:localhost)
      @plan = subscription_plans(:basic)
      AppConfig['require_payment_info_for_trials'] = true
    end
  
    should 'be invalid with an missing user' do
      @account = Account.new(:domain => 'foo')
      assert !@account.valid?
      assert @account.errors.full_messages.include?("Missing user information")
    end
  
    should 'be invalid with an invalid user' do
      @account = Account.new(:domain => 'foo', :user => User.new)
      assert !@account.valid?
      assert @account.errors.full_messages.include?("Password can't be blank")
    end
  
    should "set the full domain when created" do
      @account = Account.create(:domain => 'foo', :user => User.new(valid_user), :plan => subscription_plans(:free))
      assert_equal "foo.#{AppConfig['base_domain']}", @account.full_domain
    end
  
    should "require payment info when being created with a paid plan when the app configuration requires it" do
      @account = Account.new(:domain => 'foo', :user => User.new(valid_user), :plan => @plan)
      assert @account.needs_payment_info?
    end
  
    should "not require payment info when being created with a paid plan when the app configuration does not require it" do
      AppConfig['require_payment_info_for_trials'] = false
      @account = Account.new(:domain => 'foo', :user => User.new(valid_user), :plan => @plan)
      assert !@account.needs_payment_info?
    end
  
    should "not require payment info when being created with free plan" do
      @account = Account.new(:domain => 'foo', :user => User.new(valid_user), :plan => subscription_plans(:free))
      assert !@account.needs_payment_info?
    end
  
    should "be invalid without valid payment and address info with a paid plan" do
      @account = Account.new(:domain => 'foo', :user => User.new(valid_user), :plan => @plan)
      assert !@account.valid?
      assert @account.errors.full_messages.include?("Invalid payment information")
      assert @account.errors.full_messages.include?("Invalid address")
    end
  
    context "creating" do
      setup do
        @account = Account.create(:domain => 'foo', :user => @user = User.new(valid_user), :plan => subscription_plans(:free))
      end
      should_change 'User.count'
      should_change 'Subscription.count'
      should "set right account in subscription" do
        assert_equal @account, Subscription.find(:first, :order => 'id desc').account
      end
      should "have one admin user" do
        assert_equal @account, @user.account
        assert @account.admin
      end
    end
  
    should "delegate needs_payment_info? to subscription for existing accounts" do
      @account.subscription.expects(:needs_payment_info?)
      @account.needs_payment_info?
    end
  
    should "indicate the user limit has been reached when the number of active positions equals the user limit" do
      @account.stubs(:users).returns(OpenStruct.new(:count => @account.subscription.user_limit))
      assert @account.reached_user_limit?
    end
  
    should "not indicate the user limit has been reached when the number of active positions is less than the user limit" do
      @account.users.stubs(:count).returns(@account.subscription.user_limit - 1)
      assert !@account.reached_user_limit?
    end
  
    should "not indicate the user limit has been reached when the account has no user limit" do
      @account.subscription.user_limit = nil
      @account.users.stubs(:count).returns(1)
      assert !@account.reached_user_limit?
    end
  
    context "validating domains" do
      setup do
        @account = Account.new
      end
    
      should "prevent blank domains" do
        @account.domain = ''
        assert !@account.valid?
        assert_equal 'is invalid', @account.errors.on(:domain)
      end
    
      should "prevent duplicate domains" do
        @account.domain = 'foo'
        Account.expects(:count).with(:conditions => ['full_domain = ?', "foo.#{AppConfig['base_domain']}"]).returns(1)
        assert !@account.valid?
        assert_equal 'is not available', @account.errors.on(:domain)
      end
    
      should "prevent bad domain formats" do
        %w(foo.bar foo_bar foo-bar).each do |name|
          @account.domain = name
          assert !@account.valid?
          assert_equal 'is invalid', @account.errors.on(:domain)
        end
      end
    
      should "not allow the uniqueness check to interfere with updating an account" do
        @account = accounts(:localhost)
        Account.expects(:count).with(:conditions => ['full_domain = ? and id <> ?', @account.full_domain, @account.id]).returns(0)
        @account.name = 'Blah'
        assert @account.valid?
      end
    end
  
    ##
    ##  The following is commented out until the app is upgraded to the same
    ##  version of ActiveMerchant as we now have installed.
    ##    -- Jack, April 23, 2009
    ##
  
    context "when being created with payment info" do
      # setup do
      #   @account = Account.new(:domain => 'foo', :user => User.new(valid_user), :plan => @plan, :creditcard => @card = CreditCard.new(valid_card), :address => @address = SubscriptionAddress.new(valid_address))
      #   @account.expects(:build_subscription).with(:plan => @plan, :next_renewal_at => nil, :creditcard => @card, :address => @address).returns(@account.subscription = @subscription = Subscription.new(:plan => @plan, :creditcard => @card, :address => @address))
      #   @subscription.stubs(:gateway).returns(@gw = BogusGateway.new)
      # 
      #   SubscriptionNotifier.stubs(:deliver_welcome).returns(true)
      # end
      # 
      # context "saving account" do
      #   setup { @account.save! }
      #   should_change 'Account.count'
      #   should_change 'Subscription.count'
      #   should "set latest account" do
      #     assert_equal @account, Account.find(:first, :order => 'id desc')
      #   end
      #   should "set latest account in subscription" do
      #     assert_equal @account, Subscription.find(:first, :order => 'id desc').account
      #   end
      # end
      # 
      # context "when failing account save" do
      #   setup do
      #     @subscription.expects(:valid?).returns(false)
      #     @subscription.errors.expects(:full_messages).returns(["Forced failure"])
      #     assert @account.save
      #   end
      #   should_not_change 'Account.count'
      #   should "report errors when failing to store the CC info with BrainTree" do
      #     assert_equal ["Error with payment: Forced failure"], @account.errors.full_messages
      #   end
      # end
      # 
      # context "when saving purchase" do
      #   setup do
      #     @gw.stubs(:purchase).returns(BogusGateway::Response.new(true, 'Success'))
      #     @plan.update_attribute(:trial_period, nil)
      #     @account.save!
      #   end
      #   should_change 'SubscriptionPayment.count'
      #   should "log the initial billing, if needed" do
      #     assert_equal @account, (@sp = SubscriptionPayment.find(:first, :order => 'id desc')).account
      #     assert_equal @account.subscription, @sp.subscription
      #   end
      # end
    end
  
    context "when checking for a qualifying subscription plan" do
      setup do
        @plan = subscription_plans(:basic)
      end

      context "against the user limit" do
        setup do
          @plan.user_limit = 3
        end

        should "qualify if the plan has no user limit" do
          @plan.user_limit = nil
          @account.users.expects(:count).never
          assert @account.qualifies_for?(@plan)
        end
    
        should "qualify if the plan has a user limit greater than or equal to the number of users" do
          @account.expects(:users).returns(OpenStruct.new(:count => @plan.user_limit - 1))
          assert @account.qualifies_for?(@plan)
          @account.expects(:users).returns(OpenStruct.new(:count => @plan.user_limit))
          assert @account.qualifies_for?(@plan)
        end
    
        should "not qualify if the plan has a user limit less than the number of users" do
          @account.expects(:users).returns(OpenStruct.new(:count => @plan.user_limit + 1))
          assert !@account.qualifies_for?(@plan)
        end
      end
    
    end
  end
end
