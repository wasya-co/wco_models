
class Wco::OfficeAction
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_office_actions'

  field     :slug, type: :string
  validates :slug, uniqueness: true, allow_nil: true

  # field :descr, type: :string ## optional

  belongs_to :office_action_template, inverse_of: :office_action
  def tmpl
    office_action_template
  end

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSS         = [ STATUS_ACTIVE, STATUS_INACTIVE ]
  field :status, type: :string
  scope :active, ->{ where( status: STATUS_ACTIVE ) }

  field :perform_at, type: :time

  def to_s
    slug
  end

end

