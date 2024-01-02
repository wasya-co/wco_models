
class Wco::Lead
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_leads'

  field :email
  validates :email, presence: true, uniqueness: true
  index({ email: -1 })

  field :name
  field :phone
  field :address

  belongs_to :leadset, class_name: 'Wco::Leadset'
  has_one :photo,      class_name: 'Wco::Photo'

  has_and_belongs_to_many :conversations,           class_name: '::WcoEmail::Conversation'
  has_many                :email_contexts,          class_name: '::WcoEmail::Context'
  has_and_belongs_to_many :scheduled_email_actions, class_name: '::WcoEmail::ScheduledEmailAction'
  has_and_belongs_to_many :email_campaigns,         class_name: '::WcoEmail::Campaign'

  def self.list
    all.map { |p| [ p.id, p.email ] }
  end

  OP_DELETE = 'delete'
  OP_ADD_TO_CAMPAIGN = 'add_to_campaign'
  OPS = [ OP_DELETE, OP_ADD_TO_CAMPAIGN ]

  has_many :unsubscribes, class_name: '::WcoEmail::Unsubscribe'
  field :unsubscribe_token
  def unsubscribe_token
    if !self[:unsubscribe_token]
      update_attributes({ unsubscribe_token: (0...8).map { (65 + rand(26)).chr }.join })
    end
    self[:unsubscribe_token]
  end

end
