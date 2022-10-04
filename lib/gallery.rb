require 'kaminari/mongoid'

class Gallery
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
  include Ish::Utils

  PER_PAGE = 6

  field :name
  validates :name, :uniqueness => true
  field :subhead
  field :descr,   :as => :description

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
  field :z,       :type => Float

  field :lang,    :default => 'en'
  field :username

  field :slug
  index({ :slug => -1 }, { :unique => true })
  validates :slug, presence: true, uniqueness: true
  before_validation :set_slug, :on => :create

  def self.list conditions = { :is_trash => false }
    out = self.unscoped.where( conditions ).order_by( :created_at => :desc )
    [['', nil]] + out.map { |item| [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ] }
  end

  belongs_to :user_profile, :optional => true, :class_name => 'Ish::UserProfile', :inverse_of => :galleries

  has_many :newsitems # seems correct. _vp_ 2022-03-21
  has_many :photos

  set_callback(:create, :before) do |doc|

    #
    # newsitems
    #
    if doc.is_public

      # if doc.site
      #   sites = Site.where( :domain => doc.site.domain )
      #   sites.each do |site|
      #     n = Newsitem.new {}
      #     n.gallery = doc
      #     n.username = doc.username
      #     site.newsitems << n
      #     flag = site.save
      #     if !flag
      #       puts! site.errors
      #     end
      #   end
      # end
    end

  end

  # @deprecated, use Gallery::ACTIONS
  def self.actions
    ACTIONS
  end
  ACTIONS = [ 'show_mini', 'show_long', 'show' ]

  RENDER_TITLES = 'index_titles' # view name
  RENDER_THUMBS = 'index_thumbs' # view name

  def export_fields
    %w| name subhead descr |
  end

end

