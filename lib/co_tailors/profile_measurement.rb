
class CoTailors::ProfileMeasurement
  include Mongoid::Document
  include Mongoid::Timestamps

  UNITS = [ :inches, :centimeters ]
  field :units, :type => Symbol

  field :neck_across, :type => Float

  belongs_to :profile, :class_name => '::IshModels::UserProfile'

end

