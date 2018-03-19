
class CoTailors::Shirt
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.cost
    return 3000
  end

end

