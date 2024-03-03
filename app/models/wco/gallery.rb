
class Wco::Gallery
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  # include Wco::PremiumItem
  include Wco::Utils
  store_in collection: 'galleries'


  field :name
  validates :name, :uniqueness => true
  index({ :name => -1 }) ## 2023-09-23 removed uniqueness

  field :slug
  index({ :slug => -1 }, { :unique => true })
  validates :slug, presence: true, uniqueness: true
  before_validation :set_slug, :on => :create

  index({ created_at: -1 })
  index({ created_at: -1, name: -1 })

  field :subhead
  field :descr,   :as => :description

  field :is_public, type: Boolean, default: false

  has_and_belongs_to_many :shared_profiles, :class_name => 'Wco::Profile', :inverse_of => :shared_galleries

  def published
    where({ :is_public => true }).order_by({ :created_at => :desc })
  end

  field :x,       :type => Float
  field :y,       :type => Float
  field :z,       :type => Float

  field :lang,    :default => 'en'


  def self.list conditions = {}
    out = self.unscoped.where( conditions ).order_by( :created_at => :desc )
    [['', nil]] + out.map { |item| [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ] }
  end

  has_many :photos,    class_name: '::Wco::Photo', order: { weight: :asc }

  def export_fields
    %w| name subhead descr |
  end

  has_many :oats, class_name: 'Wco::OfficeActionTemplate'

end

