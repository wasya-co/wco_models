
class CoTailors::Merchandise
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.cost
    return 7500
  end

end

