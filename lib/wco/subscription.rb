
class Wco::Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :customer_id, type: :string # stripe
  field :price_id,    type: :string # stripe

  # belongs_to :organization, class_name: '::Wco::Organization', inverse_of: :subscriptions
  belongs_to :product,      class_name: '::Wco::Product',      inverse_of: :subscriptions

end


