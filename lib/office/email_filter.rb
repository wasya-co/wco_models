
##
## 2023-03-04 _vp_ When I receive one.
##
class Office::EmailFilter
  include Mongoid::Document
  include Mongoid::Timestamps

  field :from_regex
  field :subject_regex
  field :body_regex

  KIND_SKIP_INBOX = 'skip-inbox'
  KIND_AUTORESPOND = 'autorespond'
  KINDS = [ nil, KIND_SKIP_INBOX, KIND_AUTORESPOND ]
  field :kind

  STATE_ACTIVE = 'active'
  STATE_INACTIVE = 'inactive'
  STATES = [ STATE_ACTIVE, STATE_INACTIVE ]
  field :state, type: :string, default: STATE_ACTIVE
  scope :active, ->{ where( state: STATE_ACTIVE ) }

end

