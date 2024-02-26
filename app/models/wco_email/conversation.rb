
class WcoEmail::Conversation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'office_email_conversations'

  STATUS_UNREAD = 'status_unread'
  STATUS_READ   = 'status_read'
  STATUSES      = [ STATUS_UNREAD, STATUS_READ ]
  field :status
  scope :unread, ->{ where( status: WcoEmail::Conversation::STATUS_UNREAD ) }
  def unread?
    status == STATUS_UNREAD
  end

  field :subject
  index({ subject: -1 })

  field :latest_at
  index({ latest_at: -1 })

  field :from_emails, type: :array, default: []
  index({ from_emails: -1 })

  field :preview, default: ''

  has_many :messages,             class_name: '::WcoEmail::Message'
  # default_scope ->{ includes(:messages) }

  has_and_belongs_to_many :tags,  class_name: 'Wco::Tag', index: true
  has_and_belongs_to_many :leads, class_name: 'Wco::Lead', index: true

  belongs_to :filter, class_name: 'WcoEmail::EmailFilter', inverse_of: :conversations, optional: true



  def to_s
    "#{subject} (#{messages.length})"
  end
end
Conv = WcoEmail::Conversation
