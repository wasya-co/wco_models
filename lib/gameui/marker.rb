
class ::Gameui::Marker
  include Mongoid::Document
  include Mongoid::Timestamps


  field :slug
  ## @TODO: probably remove this, no reason not to have two markers to the same slug (destination)
  validates_uniqueness_of :slug, scope: :map_id
  validates_presence_of :slug

  field :description

  has_one :image,       class_name: '::Ish::ImageAsset', inverse_of: :marker_image
  has_one :title_image, class_name: '::Ish::ImageAsset', inverse_of: :marker_title_image

  field :deleted_at, type: Time, default: nil

  # shareable, nonpublic
  field :is_public, type: Boolean, default: true
  has_and_belongs_to_many :shared_profiles, :class_name => 'Ish::UserProfile', :inverse_of => :shared_markers
  default_scope ->{ where({ is_public: true, deleted_at: nil }).order_by({ slug: :desc }) }
  ## @TODO: index default scope, maybe instead of HABTM, use :thru for shared profiles. Make is poly anyway?

  belongs_to :map, :class_name => '::Gameui::Map'


  # @deprecated, don't use!
  # _vp_ 2021-09-23
  field :img_path
  # validates :img_path, presence: true
  field :title_img_path
  # validates :title_img_path, presence: true
  field :w, type: Integer
  validates :w, presence: true
  field :h, type: Integer
  validates :h, presence: true
  field :x, type: Integer, default: 0
  # validates :x, presence: true
  field :y, type: Integer, default: 0
  # validates :y, presence: true
  field :centerOffsetX, type: Integer, default: 0
  # validates :centerXOffset, presence: true
  field :centerOffsetY, type: Integer, default: 0
  # validates :centerYOffset, presence: true

  before_validation :compute_w_h
  def compute_w_h
    geo = Paperclip::Geometry.from_file(Paperclip.io_adapters.for(image.image))
    self.w = geo.width
    self.h = geo.height
  end

  field :is_active, type: Boolean, default: true

  field :name, type: String
  validates :name, presence: true

  field :ordering, type: String, default: 'jjj'

  ITEM_TYPE_LOCATION = 'gameui-location'
  ITEM_TYPE_MAP = 'gameui-map'
  ITEM_TYPES = [ ITEM_TYPE_LOCATION, ITEM_TYPE_MAP ]
  field :item_type, type: String
  validates :item_type, presence: true

  field :url

end

