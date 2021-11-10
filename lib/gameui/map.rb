require 'ish/premium_item'

class ::Gameui::Map
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ish::PremiumItem

  has_many :markers, :class_name => '::Gameui::Marker', inverse_of: :map

  has_many :newsitems, inverse_of: :map, order: :created_at.desc

  field :deleted_at, type: Time, default: nil

  field :slug
  validates :slug, uniqueness: true, presence: true

  field :parent_slug
  belongs_to :parent, class_name: '::Gameui::Map', inverse_of: :childs, optional: true
  has_many :childs, class_name: '::Gameui::Map', inverse_of: :parent
  has_one :image, class_name: '::Ish::ImageAsset', inverse_of: :location

  has_and_belongs_to_many :bookmarked_profiles, class_name: '::Ish::UserProfile', inverse_of: :bookmarked_location

  # shareable, nonpublic
  field :is_public, type: Boolean, default: true
  has_and_belongs_to_many :shared_profiles, :class_name => 'Ish::UserProfile', :inverse_of => :shared_locations
  default_scope ->{ where({ is_public: true, deleted_at: nil }).order_by({ slug: :desc }) }
  ## @TODO: index default scope, maybe instead of HABTM, use :thru for shared profiles. Make is poly anyway?


  field :map_slug
  def map
    ::Gameui::Map.where( slug: map_slug ).first
  end

  field :name
  field :description

  RATED_OPTIONS = [ 'pg-13', 'r', 'nc-17' ]
  field :rated, default: 'pg-13' # 'r', 'nc-17'

  ## Possible keys: description, map, markers, newsitems,
  field :labels, type: Object, default: {}
  ## Possible keys:
  ## config.description.collapsible
  field :config, type: Object, default: {}

  # @deprecated, dont use!
  field :img_path

  field :w, type: Integer
  validates :w, presence: true
  field :h, type: Integer
  validates :h, presence: true

  # @TODO: this is shared between map and marker, move to a concern.
  before_validation :compute_w_h
  def compute_w_h
    geo = Paperclip::Geometry.from_file(Paperclip.io_adapters.for(image.image))
    self.w = geo.width
    self.h = geo.height
  end

  ORDERING_TYPE_ALPHABETIC = 'alphabetic'
  ORDERING_TYPE_CUSTOM     = 'custom'
  ORDERING_TYPE_TIMESTAMP  = 'timestamp'
  ORDERING_TYPES = [ ORDERING_TYPE_ALPHABETIC, ORDERING_TYPE_CUSTOM, ORDERING_TYPE_TIMESTAMP ]
  field :ordering_type, type: String, default: 'custom' # timestamp, alphabetic, custom
  validates :ordering_type, presence: true

  def self.list conditions = { is_trash: false }
    out = self.order_by( created_at: :desc )
    [[nil, nil]] + out.map { |item| [ item.name, item.id ] }
  end

  def breadcrumbs
    out = [{ name: self.name, slug: self.slug, link: false }]
    p = self.parent
    while p
      out.push({ name: p.name, slug: p.slug })
      p = p.parent
    end
    out.reverse
  end

end

Location = ::Gameui::Map
