
class CoTailors::OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order, :class_name => 'CoTailors::Order'

  KINDS = [ :shirt, :pants, :suit ]
  field :kind, :type => Symbol

  FABRICS = [ :white, :black, :light_blue, :dark_blue, :dark_green, :pink, :gray ]
  field :fabric, :type => Symbol

  ## shirt
  # neck around
  # chest around
  # waist around
  # sleeve length
  # shoulder width
  # shirt length
  # bicep around
  # wrist around
  
  ## pants
  # length
  # waist
  # hips

end

