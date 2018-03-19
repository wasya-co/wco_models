require_relative 'order_item'

class CoTailors::Order
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :profile, :class_name => '::IshModels::UserProfile'

  has_many :items, :class_name => '::CoTailors::OrderItem'

  field :submitted_at, :type => Time

  MEASUREMENT_PARAMS = [ :neck_around, :chest_around, :waist_around, :sleeve_length, :shoulder_width, :shirt_length, :bicep_around ]

  def grand_total
    tax = 0.05
    shipping = 0 # 1200

    subtotal = items.all.map { |i| i.cost }.reduce( :+ )
    subtotal = subtotal * (tax + 1)
    subtotal += shipping
    return subtotal.to_i
  end

end

