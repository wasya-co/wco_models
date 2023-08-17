
class Wco::Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  field :product_id # stripe
  field :price_id   # stripe

  field :price_cents, type: Integer

  INTERVALS = [ nil, 'day', 'week', 'month', 'year' ]
  field :interval, type: String

  has_many :subscriptions, class_name: '::Wco::Subscription', inverse_of: :subscription

  def self.list
    [ [nil,nil] ] + self.all.map { |i| [i.name, i.id] }
  end

end
