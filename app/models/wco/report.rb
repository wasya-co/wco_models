
##
## @report.body.split("\n\n").map { |ttt| "<p>#{ttt}</p>" }.join
##
class Wco::Report
  include Mongoid::Document
  include Mongoid::Timestamps
  include Wco::Utils
  store_in collection: 'wco_reports'

  PAGE_PARAM_NAME = 'reports_page'

  field :title
  validates :title, presence: true # , uniqueness: true
  index({ title: 1 })
  def name ; title ; end

  field :subtitle
  field :legacy_id, type: String

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ :slug => 1 }, { :unique => true })
  before_validation :set_slug, on: :create

  field :body
  def body_json
    body.gsub(/\r/, '').gsub(/\n\n+/, '<br /><br />').to_json
  end

  field :x, :type => Float
  field :y, :type => Float
  field :z, :type => Float

  belongs_to :author, class_name: 'Wco::Profile'

  has_one :image_thumb, class_name: 'Wco::Photo', inverse_of: :report, dependent: :destroy
  accepts_nested_attributes_for :image_thumb

  has_and_belongs_to_many :tags

end
