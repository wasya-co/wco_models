
class Gallery
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ish::PremiumItem
  include Ish::Utils

  PER_PAGE = 6

  field :name
  validates :name, :uniqueness => true
  index({ :name => -1 }, { :unique => true })

  field :subhead
  field :descr,   :as => :description

  field :is_public, type: Boolean, default: false
  has_and_belongs_to_many :shared_profiles, :class_name => 'Ish::UserProfile', :inverse_of => :shared_galleries

  field :is_trash,   type: Boolean, default: false
  field :is_done,    type: Boolean, default: false

  def published
    where({ :is_public => true, :is_trash => false }).order_by({ :created_at => :desc })
  end

  field :x,       :type => Float
  field :y,       :type => Float
  field :z,       :type => Float

  field :lang,    :default => 'en'
  field :username
  field :lead_id, type: :integer

  field :slug
  index({ :slug => -1 }, { :unique => true })
  validates :slug, presence: true, uniqueness: true
  before_validation :set_slug, :on => :create

  def self.list conditions = { :is_trash => false }
    out = self.unscoped.where( conditions ).order_by( :created_at => :desc )
    [['', nil]] + out.map { |item| [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ] }
  end

  belongs_to :user_profile, :optional => true, :class_name => 'Ish::UserProfile', :inverse_of => :galleries

  has_many :newsitems # Seems correct. _vp_ 2022-03-21

  has_many :photos, order: { ordering: :asc }

  ACTIONS = [ 'show_mini', 'show_long', 'show' ]
  # @deprecated, use Gallery::ACTIONS
  def self.actions
    ACTIONS
  end


  RENDER_TITLES = 'index_titles' # view name
  RENDER_THUMBS = 'index_thumbs' # view name

  def export_fields
    %w| name subhead descr |
  end

end

