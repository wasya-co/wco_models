
class CoTailors::ProfileMeasurement
  include Mongoid::Document
  include Mongoid::Timestamps

  UNITS = [ :inches, :centimeters ]
  field :units, :type => Symbol

  belongs_to :profile,    :class_name => 'IshModels::UserProfile'
  belongs_to :order_item, :class_name => 'CoTailors::OrderItem'

  ## shirt
  field :neck_around,    :type => Float
  field :chest_around,   :type => Float
  field :waist_around,   :type => Float
  field :sleeve_length,  :type => Float
  field :shoulder_width, :type => Float
  field :shirt_length,   :type => Float
  field :bicep_around,   :type => Float
  field :wrist_around,   :type => Float
  ## pants
  # length
  # waist
  # hips
  ## suit

  field :nickname

end

