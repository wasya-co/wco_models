class Report
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
  include Ish::PremiumItem
  include Ish::Utils

  field :name, :type => String
  validates :name, :presence => true
  index({ :name => 1, :is_trash => 1 })

  field :slug
  validates :slug, :uniqueness => true, :presence => true
  index({ :slug => 1 }, { :unique => true })
  before_validation :set_slug, :on => :create

  field :subhead

  ## Can be one of: default (nil), longscroll,
  ##   wordpress e.g. https://piousbox.com/wp-json/wp/v2/posts?slug=intro
  # ITEM_TYPES = %w| longscroll wordpress |
  field :item_type, type: String

  field :descr, :type => String
  field :raw_json

  field :is_trash, :type => Boolean, :default => false
  index({ :is_trash => 1, :is_public => 1 })

  field :is_public, :type => Boolean, :default => true
  index({ :is_public => 1 })
  scope :public, ->{ where({ is_public: true }) }

  field :x, :type => Float
  field :y, :type => Float
  field :z, :type => Float

  belongs_to :user_profile, :optional => true, :class_name => 'Ish::UserProfile'
  has_and_belongs_to_many :shared_profiles, :class_name => 'Ish::UserProfile', :inverse_of => :shared_reports

  has_one :photo

  has_many :newsitems

  ## @TODO: trash, remove
  def self.list conditions = { :is_trash => false }
    out = self.where( conditions ).order_by( :name => :asc ).limit( 100 )
    [['', nil]] + out.map { |item| [ item.name, item.id ] }
  end

  PER_PAGE = 10
  def self.paginates_per
    self::PER_PAGE
  end

  def self.clear
    if Rails.env.test?
      self.unscoped.each { |r| r.remove }
    end
  end

  def export_fields
    %w| name descr |
  end

end
