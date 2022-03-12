require 'kaminari/mongoid'

class Gallery
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
  include Ish::Utils

  PER_PAGE = 6

  field :name
  validates :name, :uniqueness => true # , :allow_nil => false

  field :is_public,  type: Boolean, default: false
  has_and_belongs_to_many :shared_profiles, :class_name => 'Ish::UserProfile', :inverse_of => :shared_galleries

  field :is_trash,   type: Boolean, default: false
  field :is_done,    type: Boolean, default: false

  field :premium_tier, type: Integer, default: 0 # how many stars need to spend, to get access? 0 = free
  def is_premium
    premium_tier > 0
  end
  def premium?; is_premium; end
  has_many :premium_purchases, class_name: '::Gameui::PremiumPurchase', as: :item

  default_scope ->{ where({ :is_public => true, :is_trash => false }).order_by({ :created_at => :desc }) }

  field :x,       :type => Float
  field :y,       :type => Float
  field :subhead
  field :descr,   :as => :description
  field :lang,    :default => 'en'
  field :issue
  field :username

  field :slug
  index({ :slug => -1 }, { :unique => true })
  validates :slug, presence: true, uniqueness: true
  before_validation :set_slug, :on => :create

  def self.list conditions = { :is_trash => false }
    out = self.unscoped.where( conditions ).order_by( :created_at => :desc )
    [['', nil]] + out.map { |item| [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ] }
  end

  belongs_to :site,         :optional => true
  belongs_to :user_profile, :optional => true, :class_name => 'Ish::UserProfile', :inverse_of => :galleries

  has_and_belongs_to_many :tags

  has_many :newsitems
  has_many :photos

  belongs_to :city,  :optional => true
  belongs_to :venue, :optional => true


  set_callback(:create, :before) do |doc|
    if doc.user_profile && doc.user_profile.name
      doc.username = doc.user_profile.name
    end

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
    ACTIONS
  end
  ACTIONS = [ 'show_mini', 'show_long', 'show' ]

  RENDER_TITLES = 'index_titles' # view name
  RENDER_THUMBS = 'index_thumbs' # view name


  set_callback :update, :after do |doc|
    Site.update_all updated_at: Time.now
  end

  def export_fields
    %w| name descr |
  end

end

