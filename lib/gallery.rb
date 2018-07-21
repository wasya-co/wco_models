require 'kaminari/mongoid'

class Gallery
  include ::Mongoid::Document
  include ::Mongoid::Timestamps

  field :is_public,    :type => Boolean, :default => false
  field :is_trash,     :type => Boolean, :default => false

  default_scope ->{ where({ :is_public => true, :is_trash => false }).order_by({ :created_at => :desc }) }
  
  field :x, :type => Float
  field :y, :type => Float

  def self.list conditions = { :is_trash => false }
    out = self.where( conditions ).order_by( :created_at => :desc )
    [['', nil]] + out.map { |item| [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ] }
  end

  belongs_to :site, :optional => true
  # validates :site, :presence => true

  belongs_to :user_profile, :optional => true, :class_name => 'IshModels::UserProfile', :inverse_of => :galleries
  field :username, :type => String # denormalization, not used _vp_ 20171203
  has_and_belongs_to_many :shared_profiles, :class_name => 'IshModels::UserProfile', :inverse_of => :shared_galleries
  
  field :name, :type => String
  validates :name, :uniqueness => true # , :allow_nil => false

  field :galleryname, :type => String
  index({ :galleryname => -1 }, { :unique => true })
  embeds_many :gallery_names, :class_name => 'Ish::GalleryName'

  field :subhead, :type => String
  field :descr,   :type => String, :as => :description
  field :lang,    :type => String, :default => 'en'

  has_many :photos

  belongs_to :tag,   :optional => true
  belongs_to :city,  :optional => true
  belongs_to :venue, :optional => true

  has_many :newsitems


  set_callback(:create, :before) do |doc|
    if doc.user_profile && doc.user_profile.username
      doc.username = doc.user_profile.username
    end
    doc.galleryname ||= doc.id.to_s

    #
    # newsitems
    #
    if doc.is_public 
      # for the sites
      if doc.site
        sites = Site.where( :domain => doc.site.domain )
        sites.each do |site|
          n = Newsitem.new {}
          n.gallery = doc
          n.username = doc.username
          site.newsitems << n
          flag = site.save
          if !flag
            puts! site.errors
          end
        end
      end
      # for the city
      if doc.city
        n = Newsitem.new {}
        n.gallery = doc
        n.city = doc.city
        n.username = doc.username
        n.save
      end
    end

    #
    # cache
    #
    if doc.site
      doc.site.touch
    end
    if doc.city
      doc.city.touch
    end

  end

  # @deprecated, use Gallery::ACTIONS
  def self.actions
    [ 'show_mini', 'show_long', 'show' ]
  end
  ACTIONS = [ 'show_mini', 'show_long', 'show' ]

  field :issue

  RENDER_TITLES = 'gallery_render_titles_const' # string b/c transmited over http
  RENDER_THUMBS = 'gallery_render_thumbs_const' # string b/c transmited over http

end

