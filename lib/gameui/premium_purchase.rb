
class ::Gameui::PremiumPurchase
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user_profile, :class_name => '::IshModels::UserProfile'
  belongs_to :item, polymorphic: true

end

::Purchase = ::Gameui::PremiumPurchase
