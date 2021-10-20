class IshModels::UserProfile
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  validates_presence_of :name

  field :username

  field :email
  # validates_format_of :email, :with => ::Devise::email_regexp
  validates_format_of :email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  validates_uniqueness_of :email

  field :fb_access_token
  field :fb_long_access_token
  field :fb_expires_in

  field :lang, default: 'en'

  ROLES = [ :admin, :manager, :guy ]
  field :role_name, :type => Symbol

  has_one :profile_photo, :class_name => 'Photo', :inverse_of => :profile_city

  belongs_to :user
  belongs_to :current_city, :class_name => 'City', :inverse_of => :current_users, :optional => true
  belongs_to :guide_city,   :class_name => 'City', :inverse_of => :guide,         :optional => true

  has_many :galleries, :inverse_of => :user_profile
  has_and_belongs_to_many :shared_galleries, :class_name => 'Gallery', :inverse_of => :shared_profiles

  has_many :invoices, :class_name => 'Ish::Invoice'
  has_many :leads,    :class_name => 'Ish::Lead'
  has_many :photos
  has_many :reports, :inverse_of => :user_profile
  has_many :stocks,   :class_name => 'Ish::StockWatch'
  has_many :videos, :inverse_of => :user_profile
  has_many :newsitems, inverse_of: :user_profile

  has_and_belongs_to_many :bookmarked_locations, class_name: '::Gameui::Map', inverse_of: :bookmarked_profile
  def bookmarks
    bookmarked_locations
  end

  has_and_belongs_to_many :friends,   :class_name => 'IshModels::UserProfile', :inverse_of => :friendeds
  has_and_belongs_to_many :friendeds, :class_name => 'IshModels::UserProfile', :inverse_of => :friends

  field :n_unlocks, type: Integer, default: 0
  def n_coins
    n_unlocks
  end

  #
  # preferences
  #
  field :videos_embed, :type => Boolean, :default => false

  def sudoer?
    %w( piousbox@gmail.com victor@wasya.co ).include?( self.user.email ) ? true : false
  end

  # manager uses it.
  # @TODO: check this, this is shit. _vp_ 20170527
  def self.list
    out = self.all.order_by( :domain => :asc, :lang => :asc )
    [['', nil]] + out.map { |item| [ item.name, item.id ] }
  end

  #
  # CoT - colombia tailors
  #
  has_one  :measurement,  :class_name => '::CoTailors::ProfileMeasurement'
  has_many :addresses,    :class_name => '::CoTailors::Address'
  has_many :orders,       :class_name => '::CoTailors::Order'
  def current_order
    self.orders.where( :submitted_at => nil ).first || CoTailors::Order.create( :profile => self )
  end

  #
  # GameUI
  #
  field :n_stars, type: Integer, default: 0
  has_many :premium_purchases, :class_name => '::Gameui::PremiumPurchase'
  def has_premium_purchase item
    item.premium_purchases.where( user_profile_id: self.id ).exists?
  end
  def premium_purchases
    ::Gameui::PremiumPurchase.where( user_profile_id: self.id )
  end

end

Profile = IshModels::UserProfile
