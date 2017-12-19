
class CoTailors::Order
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :profile, :class_name => '::IshModels::UserProfile'

  field :submitted_at, :type => Time

end

