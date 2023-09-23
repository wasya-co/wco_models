
class Office::EmailConversationTag
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :email_conversation, class_name: 'Office::EmailConversation'

  field     :wp_term_id, type: :integer
  validates :wp_term_id, uniqueness: { scope: :email_conversation_id }, presence: true
  index({ wp_term_id: -1 })
  index({ wp_term_id: -1, latest_at: -1 })


end
