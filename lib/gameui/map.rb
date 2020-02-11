
class ::Gameui::Map
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :markers, :class_name => '::Gameui::Marker', inverse_of: :map

  field :slug
  validates :slug, uniqueness: true, presence: true

  field :w, type: Integer
  validates :w, presence: true

  field :h, type: Integer
  validates :h, presence: true

  field :description

  field :img_path

=begin
  w: 1600, h: 1000, description: 'World Map', 
      img: 'https://ish-archive.s3.amazonaws.com/2020/202002/GameUI/assets/202002_world_map/1600x1000_world-map.jpg',
=end

end

