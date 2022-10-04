
require 'ish/utils'
require 'mongoid/votable'

## @TODO: rename to Ish::Profile
class Ish::UserProfile
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Voter
  include Ish::Utils

  store_in collection: 'ish_user_profiles'

  field :email
  validates_format_of :email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  validates_uniqueness_of :email

  field :name

  def export_fields
    %w|
      email
      role_name
    |
  end

  field :scratchpad, default: ''

  field :fb_access_token
  field :fb_long_access_token
  field :fb_expires_in

  field :lang, default: 'en'

  ROLES = [ :guy, :manager, :admin ]
  ROLE_GUY     = :guy
  ROLE_MANAGER = :manager
  ROLE_ADMIN   = :admin
  field :role_name, :type => Symbol, default: :guy

  has_one :profile_photo, :class_name => 'Photo', :inverse_of => :profile_city

  # belongs_to :user
  # validates_presence_of :user

  belongs_to :current_city, :class_name => 'City', :inverse_of => :current_users, :optional => true
  belongs_to :guide_city,   :class_name => 'City', :inverse_of => :guide,         :optional => true

  has_many :galleries, :inverse_of => :user_profile
  has_and_belongs_to_many :shared_galleries, :inverse_of => :shared_profiles, class_name: 'Gallery'
  has_and_belongs_to_many :shared_markers,   :inverse_of => :shared_profiles, class_name: 'Gameui::Marker'
  has_many :my_markers,   :inverse_of => :creator_profile, class_name: 'Gameui::Marker'
  has_and_belongs_to_many :shared_locations, :inverse_of => :shared_profiles, class_name: 'Gameui::Map'
  has_many :my_maps, :inverse_of => :creator_profile, class_name: 'Gameui::Map'

  has_many :invoices,                             :class_name => '::Ish::Invoice'
  has_many :leads,                                :class_name => '::Ish::Lead'
  has_many :photos
  has_many :reports,   inverse_of: :user_profile

  ## @TODO: do something about this.
  # has_many :stock_watches,  class_name: 'IronWarbler::StockWatch'
  # has_many :option_watches, class_name: 'IronWarbler::OptionWatch'

  has_many :videos,    inverse_of: :user_profile
  has_many :newsitems, inverse_of: :profile # @TODO: remove? denorm handle over here?

  has_and_belongs_to_many :bookmarked_locations, class_name: '::Gameui::Map', inverse_of: :bookmarked_profile
  def bookmarks
    bookmarked_locations
  end

  has_and_belongs_to_many :friends,   :class_name => '::Ish::UserProfile', :inverse_of => :friendeds
  has_and_belongs_to_many :friendeds, :class_name => '::Ish::UserProfile', :inverse_of => :friends

  field :n_unlocks, type: Integer, default: 0
  def n_coins # @deprecated, do not use
    n_unlocks
  end

  ## preferences
  ## @TODO: better naming convention, or remove this
  field :videos_embed, :type => Boolean, :default => false

  def sudoer?
    %w( piousbox@gmail.com victor@wasya.co ).include?( self.email )
  end

  ## manager uses it.
  ## @TODO: check this, this is shit. _vp_ 20170527
  def self.list
    out = self.all.order_by( :domain => :asc, :lang => :asc )
    [['', nil]] + out.map { |item| [ item.name, item.id ] }
  end

  ##
  ## GameUI
  ##
  field :n_stars, type: Integer, default: 0
  has_many :premium_purchases, :class_name => '::Gameui::PremiumPurchase'
  def has_premium_purchase item
    item.premium_purchases.where( user_profile_id: self.id ).exists?
  end
  def premium_purchases
    ::Gameui::PremiumPurchase.where( user_profile_id: self.id )
  end
  field :is_purchasing, type: Boolean, default: false

  # used in rake tasks
  def self.generate delta
    email = delta[:email]
    password = delta[:password]
    role_name = delta[:role_name]

    profile = Ish::UserProfile.where( email: email ).first
    if profile
      puts! profile, "UserProfile#generate, already exists"
      return
    end

    user = User.where( email: email ).first
    if !user
      user = User.new({ email: email, password: password })
    end
    profile = Ish::UserProfile.new({
      email: email,
      role_name: role_name,
    })
    profile.save

    if profile.persisted?
      ;
    else
      puts! profile.errors.full_messages, "Cannot save profile"
    end
  end

end

Profile = Ish::UserProfile
