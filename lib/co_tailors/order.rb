
class CoTailors::Order
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :profile, :class_name => '::IshModels::UserProfile'

  has_many :items, :class_name => '::CoTailors::OrderItem'

  field :submitted_at, :type => Time

end

