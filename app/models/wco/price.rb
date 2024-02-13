
class Wco::Price
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_prices'

  ## Wco::Product, WcoHosting::ApplianceTmpl
  belongs_to :product, polymorphic: true

  belongs_to :appliance_tmpl_leadset, class_name: 'Wco::Leadset', optional: true

  has_many :subscriptions, class_name: 'Wco::Subscription', inverse_of: :price, foreign_key: :wco_price_id

  field :amount_cents, type: Integer

  INTERVAL_DAY   = 'day'
  INTERVAL_WEEK  = 'week'
  INTERVAL_MONTH = 'month'
  INTERVAL_YEAD  = 'year'
  INTERVALS      = [ nil, 'day', 'week', 'month', 'year' ]
  field :interval, type: String

  field :price_id   # stripe

  def to_s
    price = self
    "$#{ price[:amount_cents].to_f/100 }/#{ price.interval||'onetime' }"
  end
  def self.list
    [[nil,nil]] + all.map { |p| [ "#{p.product.name} :: #{p.amount_cents.to_f/100}/#{p.interval||'onetime'}", p.id ] }
  end
end


