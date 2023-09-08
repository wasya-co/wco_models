
##
## Not used. _vp_ 2023-09-07
## Just replicating the Stripe structure.
##
class Wco::Price
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :product, class_name: '::Wco::Product', inverse_of: :prices

  has_many :subscriptions, class_name: '::Wco::Subscription', inverse_of: :price, foreign_key: :wco_price_id

  field :amount_cents, type: Integer

  INTERVALS = [ nil, 'day', 'week', 'month', 'year' ]
  field :interval, type: String

  field :price_id   # stripe

  def to_s
    "$#{ amount_cents.to_f/100 } / #{interval}"
  end

end


