
##
## @report.body.split("\n\n").map { |ttt| "<p>#{ttt}</p>" }.join
##
class Wco::Report
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'wco_reports'

  field :title
  validates :title, presence: true, uniqueness: true
  index({ title: 1 }, { unique: true })
  def name ; title ; end

  field :subtitle

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ :slug => 1 }, { :unique => true })
  before_validation :set_slug, on: :create

  field :body

  field :x, :type => Float
  field :y, :type => Float
  field :z, :type => Float

  # has_one :photo

  has_and_belongs_to_many :tags

end
