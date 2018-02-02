class Video
  include Mongoid::Document
  include Mongoid::Timestamps

  PER_PAGE = 6

  field :name, :type => String
  field :descr, :type => String
  def description; descr; end

  default_scope ->{ where({ :is_public => true, :is_trash => false }).order_by({ :created_at => :desc }) }

  field :is_trash, :type => Boolean, :default => false
  field :is_public, :type => Boolean, :default => true
  field :is_feature, :type => Boolean, :default => false

  field :x, :type => Float
  field :y, :type => Float

  field :lang, :type => String, :default => 'en'

  field :youtube_id, :type => String
  validates :youtube_id, :uniqueness => true, :presence => true

  belongs_to :tag,  :optional => true
  belongs_to :city, :optional => true
  belongs_to :site, :optional => true
  has_many :newsitems

  belongs_to :user_profile, :optional => true, :class_name => 'IshModels::UserProfile', :inverse_of => :videos

  accepts_nested_attributes_for :site, :tag, :city

  def self.list
    [['', nil]] + Video.all.order_by( :created_at => :desc ).map { |item| [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ] }
  end

  set_callback( :create, :before ) do |doc|
    if doc.is_public
      doc.city.add_newsitem( doc ) unless doc.city.blank?
      doc.site.add_newsitem( doc ) unless doc.site.blank?
    end
    
  end

  field :issue

end
