
class CoTailors::ProfileMeasurement
  include Mongoid::Document
  include Mongoid::Timestamps

  UNITS = [ :inches, :centimeters ]
  UNITS_INCHES = :inches
  UNITS_CENTIMETERS = :centimeters
  field :units, :type => Symbol

  belongs_to :profile,    :class_name => 'IshModels::UserProfile', :optional => true
  belongs_to :order_item, :class_name => 'CoTailors::OrderItem',   :optional => true

  ## shirt
  field :neck_around,    :type => Float, :default => 0
  field :chest_around,   :type => Float, :default => 0
  field :waist_around,   :type => Float, :default => 0
  field :sleeve_length,  :type => Float, :default => 0
  field :shoulder_width, :type => Float, :default => 0
  field :shirt_length,   :type => Float, :default => 0
  field :bicep_around,   :type => Float, :default => 0
  field :wrist_around,   :type => Float, :default => 0 # Is this optional? I want less here
  ## pants
  # length
  # waist
  # hips
  ## suit

  field :nickname

end

