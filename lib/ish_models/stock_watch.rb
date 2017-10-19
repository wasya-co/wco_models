
class IshModels::StockWatch
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ticker

  NOTIFICATION_TYPES = [ :EMAIL, :SMS, :NONE ]
  NOTIFICATION_EMAIL = :EMAIL
  NOTIFICATION_SMS   = :SMS
  NOTIFICATION_NONE  = :NONE
  field :notification_type, :type => Symbol

  field :price, :type => Float

  DIRECTIONS      = [ :ABOVE, :BELOW ]
  DIRECTION_ABOVE = :ABOVE
  DIRECTION_BELOW = :BELOW
  field :direction, :type => Symbol

end
