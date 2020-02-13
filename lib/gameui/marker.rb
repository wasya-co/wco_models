
class ::Gameui::Marker
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :map, :class_name => '::Gameui::Map'

  field :slug
  validates :slug, uniqueness: true, presence: true

  field :w, type: Integer
  validates :w, presence: true
  field :h, type: Integer
  validates :h, presence: true
  field :x, type: Integer
  validates :x, presence: true
  field :y, type: Integer
  validates :y, presence: true

  field :img_path
  validates :img_path, presence: true
  field :title_img_path
  validates :title_img_path, presence: true

  field :description

  field :is_active, type: Boolean, default: true
  field :deleted_at, type: Time, default: nil

  field :name, type: String
  validates :name, presence: true

  field :ordering, type: String, default: 'jjj'

  ITEM_TYPE_LOCATION = 'gameui-location'
  ITEM_TYPE_MAP = 'gameui-map'
  ITEM_TYPES = [ ITEM_TYPE_LOCATION, ITEM_TYPE_MAP ]
  field :item_type, type: String
  validates :item_type, presence: true


end

