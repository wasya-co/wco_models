
class CoTailors::OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order, :class_name => 'CoTailors::Order'

  KINDS = [ :shirt, :pants, :suit ]
  field :kind, :type => Symbol

  FABRICS = [ :white, :black, :light_blue, :dark_blue, :dark_green, :pink, :gray ]
  field :fabric, :type => Symbol

  has_one :measurement, :class_name => 'CoTailors::ProfileMeasurement'

end

