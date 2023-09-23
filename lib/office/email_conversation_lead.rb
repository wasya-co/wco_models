
class Office::EmailConversationLead
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :email_conversation, class_name: 'Office::EmailConversation'

  field :lead_id, type: :integer
  validates :lead_id, uniqueness: { scope: :email_conversation_id }, presence: true

end
