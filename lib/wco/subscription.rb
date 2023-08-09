
class Wco::Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :organization, class_name: '::Wco::Organization', inverse_of: :subscriptions
  belongs_to :product,      class_name: '::Wco::Product',      inverse_of: :subscriptions

end
