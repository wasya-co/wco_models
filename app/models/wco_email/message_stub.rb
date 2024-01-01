
##
## Only object_key, no validations.
## 2023-12-28 _vp_ Continue.
##
class WcoEmail::MessageStub
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_email_message_stub'

  STATUS_PENDING   = 'status_pending'
  STATUS_PROCESSED = 'status_processed'
  STATUS_FAILED    = 'status_failed'
  STATUSES         = [ STATUS_PENDING, STATUS_PROCESSED ]
  field :status, default: STATUS_PENDING
  scope :pending, ->{ where( status: 'status_pending' ) }

  field     :object_key
  validates :object_key, presence: true, uniqueness: true
  index({ object_key: 1 }, { unique: true, name: "object_key_idx" })

  has_one :message,               class_name: 'WcoEmail::Message'

  has_and_belongs_to_many :tags,  class_name: 'Wco::Tag'

  field :config, type: Object, default: <<~AOL
    {}
  AOL

end
