
class Wco::Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :customer_id, type: :string # stripe
  field :price_id,    type: :string # stripe

  field :leadset_id

  belongs_to :product,      class_name: '::Wco::Product',      inverse_of: :subscriptions

  belongs_to :profile, class_name: '::Ish::UserProfile', optional: true, inverse_of: :subscriptions


end


