
class Wco::Organization
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :customer_id # stripe

  has_many :profiles, class_name: '::Ish::UserProfile', inverse_of: :organization
  has_many :subscriptions, class_name: '::Wco::Subscription', inverse_of: :organization

end
