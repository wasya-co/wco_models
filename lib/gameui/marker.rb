
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

  field :description


=begin
  w: 1600, h: 1000, description: 'World Map', 
      img: 'https://ish-archive.s3.amazonaws.com/2020/202002/GameUI/assets/202002_world_map/1600x1000_world-map.jpg',
=end

end

