
# require 'distribution'
# N = Distribution::Normal

class Iro::Purse
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_purses'

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ slug: -1 }, { unique: true })

  TEMPLATE_GAMEUI = 'gameui'
  TEMPLATE_TABLE  = 'table'

  has_many :positions,  class_name: 'Iro::Position', inverse_of: :purse

  has_many :strategies, class_name: 'Iro::Strategy', inverse_of: :purse

  field :unit,             type: :integer, default: 10
  ## with unit 10,  .001
  ## with unit 100, .0001
  field :summary_unit,    type: :float, default: 0.001

  field :height,           type: :integer, default: 100 ## px/q, units modal

  field :mark_every_n_usd, type: :float, default: 1
  field :n_next_positions, type: :integer, default: 5

  field :available_amount, type: :float
  # validates :available_amount, presence: true

  def to_s
    slug
  end
  def self.list
    [[nil,nil]] + all.map { |p| [p, p.id] }
  end
end
