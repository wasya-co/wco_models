
require 'ish/utils'
require 'mongoid/votable'

##
## It explicitly doesn't have a relation to user! Use email as key.
##
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

  has_one :profile_photo,                    inverse_of: :profile_city,    class_name: 'Photo'
  has_many :galleries,                       inverse_of: :user_profile
  has_and_belongs_to_many :shared_galleries, inverse_of: :shared_profiles, class_name: 'Gallery'
  has_and_belongs_to_many :shared_markers,   inverse_of: :shared_profiles, class_name: 'Gameui::Marker'
  has_and_belongs_to_many :shared_locations, inverse_of: :shared_profiles, class_name: 'Gameui::Map'
  has_many :my_markers,                      inverse_of: :creator_profile, class_name: 'Gameui::Marker'
  has_many :my_locations,                    inverse_of: :creator_profile, class_name: 'Gameui::Map'
  has_many :invoices,                                                      class_name: '::Ish::Invoice'
  has_many :photos
  has_many :reports,                         inverse_of: :user_profile
  has_many :videos,    inverse_of: :user_profile
  has_many :newsitems, inverse_of: :profile

  def sudoer?
    %w( piousbox@gmail.com victor@wasya.co ).include?( self.email )
  end

  ## manager uses it.
  ## @TODO: check this, this is shit. _vp_ 20170527
  def self.list
    out = self.all.order_by( :domain => :asc, :lang => :asc )
    [['', nil]] + out.map { |item| [ "#{item.email} :: #{item.name}", item.id ] }
  end

  field :n_unlocks, type: Integer, default: 0

  has_many :payments, :class_name => '::Ish::Payment'

  def has_premium_purchase item
    payments.where( item: item ).exists?
  end

  field :is_purchasing, type: Boolean, default: false

  has_and_belongs_to_many :friends,   :class_name => '::Ish::UserProfile', inverse_of: :friendeds
  has_and_belongs_to_many :friendeds, :class_name => '::Ish::UserProfile', inverse_of: :friends

  # used in rake tasks
  def self.generate delta
    email = delta[:email]
    password = delta[:password]
    role_name = delta[:role_name]

    profile = Ish::UserProfile.where( email: email ).first
    if profile
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
