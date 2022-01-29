
class Warbler::StockWatch
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'ish_stock_watches'

  SLEEP_TIME_SECONDS = 60

  field :ticker

  NOTIFICATION_TYPES = [ :NONE, :EMAIL, :SMS ]
  ACTIONS            = NOTIFICATION_TYPES
  NOTIFICATION_NONE  = :NONE
  NOTIFICATION_EMAIL = :EMAIL
  NOTIFICATION_SMS   = :SMS
  field :notification_type, :type => Symbol, :as => :action

  field :price, :type => Float

  DIRECTIONS      = [ :ABOVE, :BELOW ]
  DIRECTION_ABOVE = :ABOVE
  DIRECTION_BELOW = :BELOW
  field :direction, :type => Symbol

  belongs_to :profile, :class_name => 'Ish::UserProfile'

end
