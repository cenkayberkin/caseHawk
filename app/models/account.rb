class Account < ActiveRecord::Base

  has_many :users, :dependent => :destroy
  has_one :admin, :class_name => "User", :conditions => { :admin => true }
  has_many :tags
  has_many :events

  has_many :note_template_categories

  serialize :roles, Array
  serialize :case_statuses, Array

  accepts_nested_attributes_for :admin
  accepts_nested_attributes_for :note_template_categories, :allow_destroy => true,
                                :reject_if => proc { |a| a['name'].blank? }

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

  attr_accessible :name, :domain, :admin_attributes, :roles_raw, :case_statuses_raw, :note_template_categories_attributes

  acts_as_paranoid

  def roles_raw
    self.roles.join(",") unless self.roles.nil?
  end

  def roles_raw=(values)
    self.roles = []
    self.roles=values.split(",").collect(&:strip)
  end

  def case_statuses_raw
    self.case_statuses.join(",") unless self.case_statuses.nil?
  end

  def case_statuses_raw=(values)
    self.case_statuses = []
    self.case_statuses=values.split(",").collect(&:strip)
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

  protected

    def valid_domain?
      conditions = new_record? ? ['full_domain = ?', self.full_domain] : ['full_do    main = ? and id <> ?', self.full_domain, self.id]
      self.errors.add(:domain, 'is not available') if self.full_domain.blank? || self.class.count(:conditions => conditions) > 0
    end

end
