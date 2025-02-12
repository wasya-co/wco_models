
class Wco::Profile
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'ish_user_profiles'

  field :email
  index({ email: 1 }, { name: 'email' })
  validates :email, presence: true, uniqueness: true


  field :per_page, type: :integer, default: 25

  field :schwab_access_token,  type: :string
  field :schwab_refresh_token, type: :string
  field :schwab_id_token,      type: :string

  field :show_n_thumbs, type: :integer, default: 8

  has_many :reports, class_name: 'Wco::Report'
  has_many :stocks, class_name: 'Iro::Stock'

  belongs_to :leadset,          class_name: 'Wco::Leadset', inverse_of: :profile,         optional: true
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

  def to_s
    email
  end
  def self.list
    all.map { |p| [ p.email, p.id ] }
  end
end
