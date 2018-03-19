
class CoTailors::OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order, :class_name => 'CoTailors::Order'

  KIND_SHIRT = 'const-kind-shirt'
  KIND_PANTS = 'const-kind-pants'
  KIND_SUIT  = 'const-kind-suits'
  KINDS      = %w{ const-kind-shirt const-kind-pants const-kind-suits }
  field :kind, :type => String
  validates :kind, :presence => true

  FABRICS = [ :white, :black, :light_blue, :dark_blue, :dark_green, :pink, :gray ]
  field :fabric, :type => String
  validates :fabric, :presence => true

  has_one :measurement, :class_name => 'CoTailors::ProfileMeasurement'
  validates :measurement, :presence => true

  field :quantity, :type => Integer
  validates :quantity, :presence => true

  field :cost, :type => Integer # pennies!
  validates :cost, :presence => true

end

