
module Ish::PremiumItem

  def self.included base
    base.send :field, :premium_tier, type: Integer, default: 0 # how many stars need to spend, to get access? 0 = free
    base.send :has_many, :premium_purchases, class_name: '::Gameui::PremiumPurchase', as: :item
  end

  def is_premium
    premium_tier > 0
  end
  def premium?; is_premium; end

end
