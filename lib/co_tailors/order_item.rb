
class CoTailors::OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order, :class_name => '::IshModels::Order'

  KINDS = [ :shirt, :pants, :suit ]
  field :kind, :type => Symbol

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

