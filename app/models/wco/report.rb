
class Wco::Report
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'wco_reports'

  field :title
  validates :title, presence: true, uniqueness: true
  index({ title: 1 }, { unique: true })

  field :subtitle

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ :slug => 1 }, { :unique => true })
  before_validation :set_slug, :on => :create

  field :body

  # field :raw_json, type: :object, default: '{}'

  # field :is_trash, :type => Boolean, :default => false
  # index({ :is_trash => 1, :is_public => 1 })

  # field :is_public, :type => Boolean, :default => true
  # index({ :is_public => 1 })
  # scope :public, ->{ where({ is_public: true }) }

  field :x, :type => Float
  field :y, :type => Float
  field :z, :type => Float

  # has_one :photo

  def export_fields
    %w| name descr |
  end

  # has_and_belongs_to_many :tags

end
