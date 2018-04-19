class Tag  
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  # validates :name, :uniqueness => true, :allow_nil => false
  
  field :name_seo, :as => :tagname
  validates :name_seo, :uniqueness => true, :allow_nil => false
  
  field :descr, :type => String, :default => ''
  
  field :is_public, :type => Boolean, :default => true
  field :is_trash, :type => Boolean, :default => false
  field :is_feature, :type => Boolean, :default => false
  
  field :weight, :type => Integer, :default => 10

  has_many :reports
  has_many :galleries
  has_many :videos

  has_many :children_tags, :class_name => 'Tag', :inverse_of => :parent_tag
  belongs_to :parent_tag, :class_name => 'Tag', :inverse_of => :children_tags, :optional => true

  embeds_many :features
  # embeds_many :newsitems
  has_many :newsitems

  belongs_to :site, :optional => true
  belongs_to :city, :optional => true

  has_and_belongs_to_many :venues

  default_scope ->{
    where({ :is_public => true, :is_trash => false }).order_by({ :name => :asc })
  }

  before_create do |d|
    if d.name_seo.blank?
      d.name_seo = d.name.gsub(' ', '-')
    end
  end

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
