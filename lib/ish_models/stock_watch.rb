
class IshModels::StockWatch
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ticker

  NOTIFICATION_TYPES = [ :NONE, :EMAIL, :SMS ]
  NOTIFICATION_NONE  = :NONE
  NOTIFICATION_EMAIL = :EMAIL
  NOTIFICATION_SMS   = :SMS
  ACTIONS = NOTIFICATION_TYPES
  field :notification_type, :type => Symbol, :as => :action
=begin
  def action
    return notification_type
  end
  def action= which
    notification_type = which
  end
=end

  field :price, :type => Float

  DIRECTIONS      = [ :ABOVE, :BELOW ]
  DIRECTION_ABOVE = :ABOVE
  DIRECTION_BELOW = :BELOW
  field :direction, :type => Symbol

  belongs_to :profile, :class_name => 'IshModels::UserProfile'

end
