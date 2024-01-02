
class WcoEmail::Unsubscribe
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'ish_email_unsubscribes'

  field :email
  validates :email, presence: true

  field :reason
  field :unsubscribed_at

  belongs_to :campaign, class_name: 'WcoEmail::Campaign',      optional: true
  belongs_to :template, class_name: 'WcoEmail::EmailTemplate', optional: true
  belonds_to :lead,     class_name: 'Wco::Lead'


end

