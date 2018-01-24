
class CoTailors::OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order, :class_name => 'CoTailors::Order'

  KIND_SHIRT = :shirt
  KIND_PANTS = :pants
  KIND_SUIT = :suit
  KINDS = [ :shirt, :pants, :suit ]
  field :kind, :type => Symbol
  validates :kind, :presence => true

  FABRICS = [ :white, :black, :light_blue, :dark_blue, :dark_green, :pink, :gray ]
  field :fabric, :type => Symbol
  validates :fabric, :presence => true

  has_one :measurement, :class_name => 'CoTailors::ProfileMeasurement'
  validates :measurement, :presence => true

  field :quantity, :type => Integer
  validates :quantity, :presence => true

end

