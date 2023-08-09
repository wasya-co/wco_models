
class Wco::Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :product_id # stripe

  has_many :subscriptions, class_name: '::Wco::Subscription', inverse_of: :subscription

end
