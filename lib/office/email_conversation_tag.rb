
class Office::EmailConversationTag
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :email_conversation, class_name: 'Office::EmailConversation'

  field :wp_term_id, type: :integer
  validates :wp_term_id, uniqueness: { scope: :email_conversation_id }, presence: true

end
