
class Wco::Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :customer_id, type: :string # stripe
  field :price_id,    type: :string # stripe

  field :leadset_id
  def leadset
    Leadset.find leadset_id
  end

  field :quantity, type: :integer

  belongs_to :product, class_name: 'Wco::Product', inverse_of: :subscriptions
  belongs_to :price,   class_name: 'Wco::Price',   inverse_of: :subscriptions, foreign_key: :wco_price_id
  belongs_to :leadset, class_name: 'Wco::Leadset', inverse_of: :subscriptions

end


