
class ::Gameui::PremiumPurchase
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user_profile, :class_name => '::IshModels::UserProfile'

  field :purchased_class
  field :purchased_id

  belongs_to :item, polymorphic: true

end

