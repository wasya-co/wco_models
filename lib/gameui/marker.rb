
class ::Gameui::Marker
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ish::Utils

  field :name, type: String
  validates_uniqueness_of :name, scope: :map_id
  validates_presence_of :name
  def slug
    id.to_s
  end

  field :ordering, type: String, default: 'jjj'

  ITEM_TYPE_LOCATION = '::Gameui::Map' # @TODO: this used to be gameui-location . How is this different from gameui-map ?
  ITEM_TYPE_MAP = 'gameui-map'
  ITEM_TYPE_OBJ = 'gameui-obj'
  ITEM_TYPES = [ ITEM_TYPE_LOCATION, ITEM_TYPE_MAP, ITEM_TYPE_OBJ ]
  field :item_type, type: String
  validates :item_type, presence: true

  field :url
  field :version, type: String, default: '0.0.0'
  field :description

  has_one :image,       class_name: '::Ish::ImageAsset', inverse_of: :marker
  has_one :title_image, class_name: '::Ish::ImageAsset', inverse_of: :marker_title

  field :deleted_at, type: Time, default: nil # @TODO: replace with paranoia

  ## @TODO: abstract this into a module
  field :x, :type => Float, default: 0
  field :y, :type => Float, default: 0

  field :is_public, type: Boolean, default: true
  def self.public
    where( is_public: true )
  end
  ## Active AND [ mine, shared, or public ]
  def self.permitted_to profile
    active.any_of( {is_public: true},
      {:shared_profile_ids => profile.id},
      {creator_profile_id: profile.id} )
  end

  field :is_active, type: Boolean, default: true
  def self.active
    where( is_active: true )
  end

  has_and_belongs_to_many :shared_profiles, :class_name => 'Ish::UserProfile', :inverse_of => :shared_markers

  belongs_to :map,             class_name: '::Gameui::Map',    inverse_of: :markers

  belongs_to :destination, class_name: '::Gameui::Map', inverse_of: :from_markers

  belongs_to :creator_profile, class_name: 'Ish::UserProfile', inverse_of: :my_markers

  # # @deprecated, don't use!
  # # _vp_ 2021-09-23
  # field :img_path
  # # validates :img_path, presence: true
  # field :title_img_path
  # # validates :title_img_path, presence: true

  field :w, type: Integer
  validates :w, presence: true ## @TODO: why did I need this? obj markers don't have w/h
  field :h, type: Integer
  validates :h, presence: true ## @TODO: why did I need this? obj markers don't have w/h
  # @TODO: this is shared between map and marker, move to a concern.
  before_validation :compute_w_h
  def compute_w_h
    if !image # @TODO: think about this
      self.h = self.w = 0
      return
    end
    begin
      geo = Paperclip::Geometry.from_file(Paperclip.io_adapters.for(image.image))
      self.w = geo.width
      self.h = geo.height
    rescue Paperclip::Errors::NotIdentifiedByImageMagickError => e
      puts! e, 'Could not #compute_w_h'
      self.h = self.w = 0
      # @TODO: do something with this
    end
  end

  field :centerOffsetX, type: Float, default: 0
  field :centerOffsetY, type: Float, default: 0



  def export_fields
    %w|
      centerOffsetX centerOffsetY creator_profile_id
      deleted_at description destination_id
      h
      is_active is_public item_type
      map_id
      name
      ordering
      slug
      url
      version
      w
      x
      y
    |
  end

  def collect export_object
    puts! export_object, "collecting in marker: |#{slug}|."

    if image
      export_object[:image_assets][image.id.to_s] = image.id.to_s
    end
    if title_image
      export_object[:image_assets][title_image.id.to_s] = title_image.id.to_s
    end
    if !export_object[:maps][destination.id.to_s]
      destination.collect export_object
    end
  end

end

Marker = Gameui::Marker