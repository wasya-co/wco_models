
##
## 2023-09-13 _vp_ I don't know if it's even used.
##
class Office::Action
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'office_actions'

  field     :slug, type: :string
  validates :slug, uniqueness: true, allow_nil: true

  field :descr, type: :string ## optional


  STATE_ACTIVE   = 'active'
  STATE_INACTIVE = 'inactive'
  STATES         = [ STATE_ACTIVE, STATE_INACTIVE ]
  field :state, type: :string
  scope :active, ->{ where( state: STATE_ACTIVE ) }


  has_many :ties,      class_name: '::Office::ActionTie', inverse_of: :office_action
  has_many :prev_ties, class_name: '::Office::ActionTie', inverse_of: :next_office_action
  accepts_nested_attributes_for :ties

  field :action_exe, type: :string

  field :perform_at, type: :time

end
OAct = Office::Action
