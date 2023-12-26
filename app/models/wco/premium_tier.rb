
module Wco::PremiumItem

  def self.included base
    base.send :field, :premium_tier, type: Integer, default: 0 # how many unlocks are need, to get access? 0 = free
    base.send :has_many, :premium_purchases, class_name: '::Ish::Payment', as: :item
  end

  def is_premium
    premium_tier > 0
  end

end
