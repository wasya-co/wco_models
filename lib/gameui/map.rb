
require 'ish/premium_item'
require 'ish/utils'

class ::Gameui::Map
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ish::PremiumItem
  include Ish::Utils

  field :name

  field :slug
  validates :slug, uniqueness: true, presence: true

  field :description

  ## @TODO: probably, abstract this. _vp_ 2022-09-20
  field :deleted_at, type: Time, default: nil

  has_many :markers,      :class_name => '::Gameui::Marker', inverse_of: :map
  has_many :from_markers, :class_name => '::Gameui::Marker', inverse_of: :destination

  has_many :newsitems, inverse_of: :map, order: :created_at.desc

  # @TODO: remove field, replace with relation. _vp_ 2022-09-13
  field :parent_slug
  belongs_to :parent, class_name: '::Gameui::Map', inverse_of: :childs, optional: true
  has_many :childs, class_name: '::Gameui::Map', inverse_of: :parent

  has_one :image, class_name: '::Ish::ImageAsset', inverse_of: :location
  belongs_to :creator_profile, class_name: '::Ish::UserProfile', inverse_of: :my_maps

  has_and_belongs_to_many :bookmarked_profiles, class_name: '::Ish::UserProfile', inverse_of: :bookmarked_location
  has_and_belongs_to_many :tags, class_name: 'Tag', inverse_of: :map

  # shareable, nonpublic
  field :is_public, type: Boolean, default: true
  has_and_belongs_to_many :shared_profiles, :class_name => 'Ish::UserProfile', :inverse_of => :shared_locations

  field :version, type: String, default: '0.0.0'

  ## @TODO: or self, right? and refactor this, seems N+1. _vp_ 2022-09-13
  field :map_slug
  def map
    ::Gameui::Map.where( slug: map_slug ).first
  end

  RATED_OPTIONS = [ 'pg-13', 'r', 'nc-17' ]
  field :rated, default: 'pg-13' # 'r', 'nc-17'

  ## Possible keys: description, map, markers, newsitems,
  field :labels, type: Object, default: {}
  ## Possible keys:
  ## config.description.collapsible
  field :config, type: Object, default: {}

  # @deprecated, dont use!
  field :img_path

  ## Not used! See config.map_panel_type instead.
  # MAP_TYPES = [ :map_2d, :map_3d, :map_geospatial, :map_gallery, :map_toc ] ## Mostly not implemented. _vp_ 2022-09-06
  # field :map_type, default: :map_2d

  ## Make sure to use x,y,z and w,h as appropriate.
  ## @TODO: abstract this into a module
  field :x, type: Float
  field :y, type: Float
  field :z, type: Float

  ## Make sure to use x,y,z and w,h as appropriate.
  field :w, type: Integer
  validates :w, presence: true
  field :h, type: Integer
  validates :h, presence: true
  # @TODO: this is shared between map and marker, move to a concern.
  before_validation :compute_w_h
  def compute_w_h
    return if !image ## @TODO: test this

    begin
      geo = Paperclip::Geometry.from_file(Paperclip.io_adapters.for(image.image))
      self.w = geo.width
      self.h = geo.height
    rescue Paperclip::Errors::NotIdentifiedByImageMagickError => e
      puts! e, 'Could not #compute_w_h'
      # @TODO: do something with this
    end
  end

  ORDERING_TYPE_ALPHABETIC = 'alphabetic'
  ORDERING_TYPE_CUSTOM     = 'custom'
  ORDERING_TYPE_TIMESTAMP  = 'timestamp'
  ORDERING_TYPES = [ ORDERING_TYPE_ALPHABETIC, ORDERING_TYPE_CUSTOM, ORDERING_TYPE_TIMESTAMP ]
  field :ordering_type, type: String, default: 'custom' # timestamp, alphabetic, custom
  validates :ordering_type, presence: true

  def self.list conditions = { is_trash: false }
    out = self.order_by( created_at: :desc )
    [[nil, nil]] + out.map { |item| [ item.name, item.id.to_s ] }
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

  ##
  ## @TODO: move the export func, below, to a module. _vp_ 2022-09-20
  ##

  def empty_export
    return {
      galleries: {},
      image_assets: {},
      maps: {}, markers: {},
      newsitems: {},
      photos: {}, profiles: {},
      reports: {},
      videos: {},
    }
  end
  def self.empty_export; Gameui::Map.new.empty_export; end

  def empty_export_arr
    return {
      galleries: [],
      image_assets: [],
      maps: [], markers: [],
      newsitems: [],
      photos: [], profiles: [],
      reports: [],
      videos: [],
    }
  end

  def export_key_to_class
    return {
      galleries: 'Gallery',
      image_assets: 'Ish::ImageAsset',
      maps: 'Gameui::Map',
      markers: 'Gameui::Marker',
      newsitems: 'Newsitem',
      photos: 'Photo',
      profiles: 'Ish::UserProfile',
      reports: 'Report',
      videos: 'Video',
      # 'galleries' => 'Gallery',
      # 'image_assets' => 'Ish::ImageAsset',
      # 'maps' => 'Gameui::Map',
      # 'markers' => 'Gameui::Marker',
      # 'newsitems' => 'Newsitem',
      # 'photos' => 'Photo',
      # 'profiles' => 'Ish::UserProfile',
      # 'reports' => 'Report',
      # 'videos' => 'Video',
    }.with_indifferent_access
  end
  def self.export_key_to_class
    Map.new.export_key_to_class
  end

  def export_fields
    %w|
      creator_profile_id config
      deleted_at description
      h
      is_public
      labels
      map_slug
      name
      ordering_type
      parent_slug
      rated
      slug
      version
      w
    |
  end

  ## This is the starting point _vp_ 2022-03-12
  ##
  def export_subtree
    collected = collect(empty_export)
    exportable = empty_export_arr
    collected.map do |k, v|
      if v.present?
        v.map do |id|
          id = id[0]
          item = export_key_to_class[k].constantize.unscoped.find id
          export = item.export
          exportable[k].push( export )
        end
      end
    end
    JSON.pretty_generate exportable
  end

  def collect export_object
    map = self
    export_object[:maps][map.id.to_s] = map.id.to_s

    if map.markers.present?
      map.markers.map do |marker|
        id = marker.id.to_s
        if !export_object[:markers][id]
          marker.collect( export_object )
        end
        export_object[:markers][id] = id
      end
    end

    if map.newsitems.present?
      map.newsitems.map do |newsitem|
        id = newsitem.id.to_s
        export_object[:newsitems][id] = id
        newsitem.collect export_object
      end
    end

    ## @TODO: maybe implement this later, maybe not. _vp_ 2022-03-12
    # if map.childs.present?
    #   export_object[:maps].push( map.childs.map &:id )
    #   map.childs.map do |child|
    #     child.collect export_object
    #   end
    # end

    if map.creator_profile.present?
      export_object[:profiles][map.creator_profile.id.to_s] = map.creator_profile.id.to_s
    end

    if map.image.present?
      export_object[:image_assets][map.image.id.to_s] = map.image.id.to_s
    end

    export_object
  end

  ## endExport

  field :newsitems_page_size, default: 25

end

Location = ::Gameui::Map
Map = Gameui::Map
