
class Wco::Subscription
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_subscriptions'

  belongs_to :product, polymorphic: true # includes: Wco::Product , WcoHosting::ApplianceTmpl

  belongs_to :price,   class_name: 'Wco::Price',   inverse_of: :subscriptions, foreign_key: :wco_price_id
  field :price_id # stripe

  belongs_to :leadset, class_name: 'Wco::Leadset', inverse_of: :subscriptions
  field :customer_id # stripe

  field :quantity,    type: :integer


end


