class Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ish::Utils

  field :name, :type => String
  # validates :name, :uniqueness => true, :allow_nil => false

  field :slug
  validates :slug, :uniqueness => true, presence: true, allow_nil: false

  field :descr, :type => String, :default => ''

  field :is_public, :type => Boolean, :default => true
  field :is_trash, :type => Boolean, :default => false
  field :is_feature, :type => Boolean, :default => false

  field :weight, :type => Integer, :default => 10

  has_many :children_tags, :class_name => 'Tag', :inverse_of => :parent_tag
  belongs_to :parent_tag, :class_name => 'Tag', :inverse_of => :children_tags, :optional => true

  has_many :features
  has_many :newsitems

  belongs_to :site, :optional => true
  belongs_to :city, :optional => true

  has_and_belongs_to_many :venues
  has_and_belongs_to_many :cities
  has_and_belongs_to_many :galleries
  has_and_belongs_to_many :reports
  has_and_belongs_to_many :videos

  default_scope ->{
    where({ :is_public => true, :is_trash => false }).order_by({ :name => :asc })
  }

  before_validation :set_slug

  def self.clear
    if Rails.env.test?
      Tag.each { |r| r.remove }
    end
  end

  def self.no_parent
    Tag.where( :parent_tag_id => nil )
  end

  # the first blank used to be disabled, not anymore _vp_ 20180418
  def self.list
    out = Tag.unscoped.order_by( :name => :asc )
    return( [['', nil]] + out.map { |item| [ item.name, item.id ] } )
  end

  # @deprecated, there will be no reports or galleries in tags. There will be only features and newsitems
  def self.n_items
    10
  end
  def self.n_reports
    4
  end
  def self.n_galleries
    4
  end
  def self.n_videos
    4
  end

  # @deprecated I don't even know why I have this. Should be simplified into non-being.
  def self.n_features
    4
  end

end
