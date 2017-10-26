
#
# Stock Option. Owned by a person. This is a position that is held (or historical data).
# _vp_ 20171026
#
class Ish::StockOption
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :collection => 'ish_stock_watch'

  field :ticker

  NOTIFICATION_TYPES = [ :NONE, :EMAIL, :SMS ]
  NOTIFICATION_NONE  = :NONE
  NOTIFICATION_EMAIL = :EMAIL
  NOTIFICATION_SMS   = :SMS
  ACTIONS = NOTIFICATION_TYPES
  field :notification_type, :type => Symbol, :as => :action
  field :price, :type => Float

  DIRECTIONS      = [ :ABOVE, :BELOW ]
  DIRECTION_ABOVE = :ABOVE
  DIRECTION_BELOW = :BELOW
  field :direction, :type => Symbol

  belongs_to :profile, :class_name => 'IshModels::UserProfile'

end
