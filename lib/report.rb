class Report
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
  include Ish::Utils

  field :name, :type => String
  validates :name, :presence => true
  # index({ :name => 1 }, { :unique => true })
  index({ :name => 1, :is_trash => 1 })

  field :slug
  validates :slug, :uniqueness => true, :presence => true
  index({ :slug => 1 }, { :unique => true })
  before_validation :set_slug, :on => :create

  ## Can be one of: default (nil), longscroll,
  ##   wordpress e.g. https://piousbox.com/wp-json/wp/v2/posts?slug=intro
  # ITEM_TYPES = %w| longscroll wordpress |
  field :item_type, type: String

  field :descr, :type => String
  field :raw_json

  field :is_trash, :type => Boolean, :default => false
  index({ :is_trash => 1, :is_public => 1 }, { name: 'default_index' })

  field :is_public, :type => Boolean, :default => true
  index({ :is_public => 1 })
  scope :public, ->{
    where({ is_public: true })
  }

  field :is_feature, :type => Boolean, :default => false
  index({ :is_feature => 1 })

  field :is_done, :type => Boolean, :default => true
  index({ :is_done => 1 })

  field :x, :type => Float
  field :y, :type => Float

  field :lang, :type => String, :default => 'en'
  index({ :lang => 1 })

  belongs_to :user_profile, :optional => true, :class_name => 'Ish::UserProfile'

  # validates :user, :presence => true, :allow_nil => false
  field :username, :type => String, :default => 'anonymous'
  validates :username, :presence => true, :allow_nil => false
  index({ :username => 1 })

  field :issue
  field :subhead

  has_one :photo

  field :n_upvotes, :default => 0
  field :n_spamvotes, :default => 0

  default_scope ->{
    where({ is_public: true, is_trash: false }).order_by({ created_at: :desc })
  }

  has_many :newsitems

  def self.list conditions = { :is_trash => false }
    out = self.where( conditions ).order_by( :name => :asc ).limit( 100 )
    [['', nil]] + out.map { |item| [ item.name, item.id ] }
  end

  PER_PAGE = 10
  def self.paginates_per
    self::PER_PAGE
  end

  def self.all
    self.where( :is_public => true, :is_trash => false ).order_by( :created_at => :desc )
  end

  def self.clear
    if Rails.env.test?
      self.unscoped.each { |r| r.remove }
    end
  end

  ## copy-paste
  field :premium_tier, type: Integer, default: 0 # how many stars need to spend, to get access? 0 = free
  def is_premium
    premium_tier > 0
  end
  def premium?; is_premium; end
  has_many :premium_purchases, class_name: '::Gameui::PremiumPurchase', as: :item

  def export_fields
    %w| name descr |
  end

end
