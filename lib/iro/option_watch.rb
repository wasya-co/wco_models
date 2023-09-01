
##
## for alerting
##
class Iro::OptionWatch
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_option_watches'

  field :ticker # like NVDA
  validates :ticker, presence: true

  field :symbol # like NVDA_021822C230

  KIND_OPTION     = 'option'
  KIND_STOCK      = 'stock'
  KIND_GET_CHAINS = 'get-chains'
  KINDS       = [ KIND_OPTION, KIND_STOCK, KIND_GET_CHAINS ]
  field :kind, type: String
  validates :kind, presence: true
  def self.kinds_list
    [ nil, 'option', 'stock' ]
  end

  ## Strike isn't the same as price!
  field :strike, :type => Float
  # validates :strike, presence: true

  ## What is the price of the option at some strike?
  field :mark, type: Float
  validates :mark, presence: true

  field :contractType
  # validates :contractType, presence: true

  field :expirationDate
  # validates :expirationDate, presence: true

  NOTIFICATION_TYPES = [ :NONE, :EMAIL, :SMS ]
  ACTIONS            = NOTIFICATION_TYPES
  NOTIFICATION_NONE  = :NONE
  NOTIFICATION_EMAIL = :EMAIL
  NOTIFICATION_SMS   = :SMS
  field :notification_type, :type => Symbol, :as => :action
  def self.actions_list
    [nil] + ACTIONS
  end

  STATE_ACTIVE   = 'active'
  STATE_INACTIVE = 'inactive'
  STATES         = [ STATE_ACTIVE, STATE_INACTIVE ]
  field :state, type: String, default: STATE_ACTIVE
  validates :state, presence: true
  scope :active, ->{ where( state: STATE_ACTIVE ) }
  def self.states_list
    [ nil, 'active', 'inactive' ]
  end

  DIRECTION_ABOVE = :ABOVE
  DIRECTION_BELOW = :BELOW
  DIRECTIONS      = [ :ABOVE, :BELOW ]
  field :direction, :type => Symbol
  validates :direction, presence: true
  def self.directions_list
    [nil] + DIRECTIONS
  end

  belongs_to :profile, :class_name => 'Ish::UserProfile'
  field :email
  field :phone

end
