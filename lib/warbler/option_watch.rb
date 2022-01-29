
class Warbler::OptionWatch
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'ish_option_watches'

  SLEEP_TIME_SECONDS = 60

  field :ticker # like NVDA
  validates :ticker, presence: true
  # field :symbol # like NVDA_021822C230

  ## Strike isn't called price!
  field :strike, :type => Float
  validates :strike, presence: true

  field :contractType
  validates :contractType, presence: true

  field :date
  validates :date, presence: true

  NOTIFICATION_TYPES = [ :NONE, :EMAIL, :SMS ]
  ACTIONS            = NOTIFICATION_TYPES
  NOTIFICATION_NONE  = :NONE
  NOTIFICATION_EMAIL = :EMAIL
  NOTIFICATION_SMS   = :SMS
  field :notification_type, :type => Symbol, :as => :action

  DIRECTIONS      = [ :ABOVE, :BELOW ]
  DIRECTION_ABOVE = :ABOVE
  DIRECTION_BELOW = :BELOW
  field :direction, :type => Symbol

  belongs_to :profile, :class_name => 'Ish::UserProfile'

end
