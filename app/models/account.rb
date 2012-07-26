class Account < ActiveRecord::Base
  
  has_many :users, :dependent => :destroy
  has_one :admin, :class_name => "User", :conditions => { :admin => true }
  has_many :tags
  has_many :events
  has_one :subscription, :dependent => :destroy
  has_many :subscription_payments

  accepts_nested_attributes_for :admin

  #
  # Set up the account to own subscriptions. An alternative would be to
  # call 'has_subscription' on the user model, if you only want one user per
  # subscription.  See has_subscription in vendor/plugins/saas/lib/saas.rb
  # for info on how to use the options for implementing limit checking.
  #
  has_subscription :user_limit => Proc.new {|a| a.users.count }

  #
  # The model with "has_subscription" needs to provide an email attribute.
  # But ours is stored in the user model, so we delegate
  #
  delegate :email, :to => :admin
  
  validates_format_of :domain, :with => /\A[a-zA-Z][a-zA-Z0-9]*\Z/
  validates_exclusion_of :domain, :in => %W( support blog www billing help api ), :message => "The domain <strong>{{value}}</strong> is not available."
  validates_presence_of :admin, :on => :create, :message => "information is missing"
  validates_associated :admin, :on => :create
  validate :valid_domain?
 
  validate :valid_user?, :on => :create
  validate :valid_plan?, :on => :create
  validate :valid_payment_info?, :on => :create
  validate :valid_subscription?, :on => :create
  
  attr_accessible :name, :domain, :user, :plan, :plan_start, :creditcard, :address, :admin_attributes
  attr_accessor :user, :plan, :plan_start, :creditcard, :address
  
  after_create :create_admin
  after_create :send_welcome_email
  
  acts_as_paranoid

  Limits = {
    'user_limit' => Proc.new {|a| a.users.count }
  }
  
  Limits.each do |name, meth|
    define_method("reached_#{name}?") do
      return false unless self.subscription
      self.subscription.send(name) && self.subscription.send(name) <= meth.call(self)
    end
  end
  
  def domain
    @domain ||= self.full_domain.blank? ? '' : self.full_domain.split('.').first
  end
  
  def domain=(domain)
    @domain = domain
    self.full_domain = "#{domain}.#{Saas::Config.base_domain}"
  end
  
  def to_s
    name.blank? ? full_domain : "#{name} (#{full_domain})"
  end

  def needs_payment_info?
    if new_record?
      AppConfig['require_payment_info_for_trials'] && @plan && @plan.amount > 0
    else
      self.subscription.needs_payment_info?
    end
  end

  # Does the account qualify for a particular subscription plan
  # based on the plan's limits
  def qualifies_for?(plan)
    Subscription::Limits.keys.collect{ |rule| rule.call(self, plan) }.all?
  end
  
  def active?
    self.subscription.next_renewal_at >= Time.now
  end

  protected
  
    def valid_domain?
      invalid = %w( support blog www billing help api admin root system sys file files )
      conditions = new_record? ? ['full_domain = ?', self.full_domain] : ['full_domain = ? and id <> ?', self.full_domain, self.id]
      self.errors.add(:domain, 'is not available') if 
        self.full_domain.blank? || 
        invalid.include?(self.full_domain) || 
        self.class.count(:conditions => conditions) > 0
    end

# An account must have an associated user to be the administrator
    def valid_user?
      if !@user
        errors.add_to_base("Missing user information")
      elsif !@user.valid?
        @user.errors.full_messages.each do |err|
          errors.add_to_base(err)
        end
      end
    end
    
    def valid_payment_info?
      if needs_payment_info?
        unless @creditcard && @creditcard.valid?
          errors.add_to_base("Invalid payment information")
        end
        
        unless @address && @address.valid?
          errors.add_to_base("Invalid address")
        end
      end
    end
    
    def valid_plan?
      errors.add_to_base("Invalid plan selected.") unless @plan
    end
    
    def valid_subscription?
      return if errors.any? # Don't bother with a subscription if there are errors already
      self.build_subscription(:plan => @plan, :next_renewal_at => @plan_start, :creditcard => @creditcard, :address => @address)
      if !subscription.valid?
        errors.add_to_base("Error with payment: #{subscription.errors.full_messages.to_sentence}")
        return false
      end
    end
    
    def create_admin
      self.user.admin = true
      self.user.account = self
      self.user.save
    end
    
    def send_welcome_email
      SubscriptionNotifier.deliver_welcome(self)
    end

end
