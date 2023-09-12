
class Wco::Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  field :product_id # stripe

  ## @TODO: remove, interval makes no sense on product! replace with Wco::Price . _vp_ 2023-09-07
  # has_many :subscriptions, class_name: '::Wco::Subscription', inverse_of: :subscription

  has_many :prices,        class_name: '::Wco::Price', inverse_of: :product

  def self.list
    [ [nil,nil] ] + self.all.order_by({ name: :asc }).map { |i| [i.name, i.id] }
  end

end









  ## @TODO: remove, interval makes no sense on product! replace with Wco::Price . _vp_ 2023-09-07
  # INTERVALS = [ nil, 'day', 'week', 'month', 'year' ]
  # field :interval, type: String
  ## @TODO: remove, interval makes no sense on product! replace with Wco::Price . _vp_ 2023-09-07
  # field :price_id   # stripe
  ## @TODO: remove, interval makes no sense on product! replace with Wco::Price . _vp_ 2023-09-07
  # field :price_cents, type: Integer
