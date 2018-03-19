
class CoTailors::Suit
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.cost
    return 30000
  end

end

