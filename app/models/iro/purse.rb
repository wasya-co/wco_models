
# require 'distribution'
# N = Distribution::Normal

class Iro::Purse
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'iro_purses'

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ slug: -1 }, { unique: true })

  has_many :positions,  class_name: 'Iro::Position', inverse_of: :purse

  # has_and_belongs_to_many :strategies, class_name: 'Iro::Strategy', inverse_of: :purses
  # belongs_to :stock, class_name: 'Iro::Stock', inverse_of: :strategies

  field :unit,             type: :integer, default: 10
  ## with unit 10,  .001
  ## with unit 100, .0001
  field :summary_unit,    type: :float, default: 0.001

  ## for rolling only:
  field :height,           type: :integer, default: 100

  field :mark_every_n_usd, type: :float, default: 1
  field :n_next_positions, type: :integer, default: 5

  field :available_amount, type: :float
  def available
    available_amount
  end

  def balance
    0.01
  end

  def delta_wt_avg( begin_end, long_short, inner_outer )
    max_loss_total = 0

    out = positions.send( long_short ).map do |pos|
      max_loss_total += pos.max_loss * pos.q
      pos.max_loss * pos.q * pos.send( inner_outer ).send( "#{begin_end}_delta" )
    end
    # puts! out, 'delta_wt_avg 1'
    out = out.reduce( &:+ ) / max_loss_total rescue 0
    # puts! out, 'delta_wt_avg 2'
    return out
  end
  ## delta to plot percentage
  ## convert to normal between 0 and 3 std
  def delta_to_plot_p( *args )
    x = delta_wt_avg( *args ).abs
    if x < 0.5
      y = 1
    else
      y = 2 - 1/( 1.5 - x )
    end
    y_ = "#{ (y*100) .to_i}%"
    return y_
  end

  def to_s
    slug
  end
  def self.list
    [[nil,nil]] + all.map { |p| [p, p.id] }
  end
end
