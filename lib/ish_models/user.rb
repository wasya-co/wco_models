
class IshModels::User  
  include Mongoid::Document
  include Mongoid::Timestamps

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me

  ## Database authenticatable
  field :email, type: String, default: ""
  validates :email, :presence => true, :uniqueness => true

  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time
  
  # :recoverable, :trackable :rememberable,
  # :token_authenticatable, 
  # :lockable, :timeoutable, :confirmable

  # herehere, this was in (now its out)
  # devise :registerable, :validatable
  # devise :database_authenticatable, :authentication_keys => [ :email ]

  # devise :omniauthable, :omniauth_providers => [ :facebook ]
  # devise :encryptable, :encryptor => :sha1base64
  #
  #
  # field :confirmed_at, :type => DateTime
  # field :confirmation_token, :type => String
  # field :confirmation_sent_at, :type => DateTime
  
  field :username, :type => String
  validates :username, :presence => true, :uniqueness => true
  
  field :name, :type => String
  validates :name, :presence => true
  
  field :group_id, :type => Integer, :default => 3

  field :scratchpad, :type => String
  field :github_path, :type => String
  field :facebook_path, :type => String
  field :stackoverflow_path, :type => String

  field :is_feature, :type => Boolean, :default => false
  field :is_trash, :type => Boolean, :default => false

  field :display_ads, :type => Boolean, :default => true
  field :display_help, :type => Boolean, :default => true
  
  has_many :reports
  has_many :photos
  has_many :user_profiles
  has_many :galleries
  has_many :videos

  has_one :profile_photo, :class_name => 'Photo', :inverse_of => :profile_user

  has_and_belongs_to_many :viewable_photos, :class_name => 'Photo', :inverse_of => :viewer

  belongs_to :guide_city, :class_name => 'City', :inverse_of => :guide
  belongs_to :current_city, :class_name => 'City', :inverse_of => :city_users

  def self.list conditions = { :is_trash => false }
    out = self.where( conditions ).order_by( :name => :asc )
    [['', nil]] + out.map { |item| [ item.name, item.id ] }
  end

  embeds_many :newsitems

  def self.all
    self.where( :is_trash => false ).order_by( :created_at => :desc )
  end

  def create_newsitem args = {}
    unless args[:photo].blank?
      n = Newsitem.new
      n.photo = args[:photo]
      n.descr = 'uploaded new photo on'
      n.username = self.username
      self.newsitems << n
      self.save
    end
  end
  
  def self.per_page
    16
  end

  def self.clear
    if Rails.env.test?
      User.unscoped.each { |u| u.remove }
    end
  end
  
  def generate_auth_token
    payload = { user_id: self.id }
    AuthToken.encode(payload)
  end
  
end
