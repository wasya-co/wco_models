
class Wco::Profile
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'ish_user_profiles'

  field :email
  index({ email: 1 }, { name: 'email' })
  validates :email, presence: true, uniqueness: true

  field :name
  field :descr


  field :per_page, type: :integer, default: 25
  field :show_n_thumbs, type: :integer, default: 8


  field :schwab_access_token,  type: :string
  field :schwab_refresh_token, type: :string
  field :schwab_id_token,      type: :string

  field :schwab_exec_access_token,  type: :string
  field :schwab_exec_refresh_token, type: :string
  field :schwab_exec_id_token,      type: :string
  field :schwab_account_hash,       type: :string

  field :smtp_enabled, type: Boolean
  field :smtp_host
  field :smtp_username
  field :smtp_password
  field :smtp_port

  field :linkedin_client_id
  field :linkedin_client_secret
  field :linkedin_access_token


  has_many :newsvideos, class_name: 'Wco::Newsvideo'
  has_many :reports, class_name: 'Wco::Report'
  has_many :stocks, class_name: 'Iro::Stock'
  has_many :sidebar_tags, class_name: 'Wco::Tag', inverse_of: :sidebar_profile

  belongs_to :leadset, class_name: 'Wco::Leadset', inverse_of: :profile
  has_many :newsitems, class_name: 'Wco::Newsitem'
  has_and_belongs_to_many :shared_galleries, class_name: 'Wco::Gallery', inverse_of: :shared_profiles

  field :sentiment, default: Iro::Stock::LONG_OR_SHORT
  field :sentiment_num, default: 0 # 1 is very long, -1 is very short

  ROLE_ADMIN = 'admin'
  ROLE_GUY   = 'guy'
  ROLES      = [ ROLE_ADMIN, ROLE_GUY ]
  field :role, type: :string, default: ROLE_GUY
  def self.roles_list
    [nil] + ROLES
  end

  def self.ai_writer
    find_or_create_by email: 'ai-writer@wasya.co'
  end

  def self.pi
    find_by email: 'piousbox@gmail.com'
  end

  def to_s
    email
  end
  def self.list
    all.map { |p| [ p.email, p.id ] }
  end
end
