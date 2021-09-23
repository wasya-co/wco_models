
class ::Gameui::Map
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :markers, :class_name => '::Gameui::Marker', inverse_of: :map
  has_many :newsitems, inverse_of: :map

  field :slug
  validates :slug, uniqueness: true, presence: true

  field :parent_slug
  belongs_to :parent, class_name: '::Gameui::Map', inverse_of: :childs, optional: true
  has_many :childs, class_name: '::Gameui::Map', inverse_of: :parent
  has_one :image_asset, class_name: '::Ish::ImageAsset'

  has_and_belongs_to_many :bookmarked_profiles, class_name: '::IshModels::UserProfile', inverse_of: :bookmarked_location

  field :map_slug
  def map
    ::Gameui::Map.where( slug: map_slug ).first
  end

  field :name

  field :w, type: Integer
  validates :w, presence: true

  field :h, type: Integer
  validates :h, presence: true

  field :description

  field :img_path

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
