

class Wco::Newsvideo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'wco_newsvideos'

  PAGE_PARAM_NAME = 'newsvideos_page'

  field :title
  validates :title, presence: true, uniqueness: true
  index({ title: 1 }, { unique: true })
  def name ; title ; end
  def to_s
    title
  end

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ :slug => 1 }, { :unique => true })
  before_validation :set_slug, on: :create

  field :body
  field :config_json, type: :string

  field :x, :type => Float
  field :y, :type => Float
  field :z, :type => Float

  # has_one :image_thumb
  # has_one :image_hero

  belongs_to :author, class_name: 'Wco::Profile'

  has_and_belongs_to_many :tags
  has_many :newspartials
  has_many :videos

end
