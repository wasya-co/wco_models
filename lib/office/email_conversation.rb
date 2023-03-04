
class Office::EmailConversation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  STATE_UNREAD = 'state_unread'
  STATE_READ = 'state_read'
  STATES = [ STATE_UNREAD, STATE_READ ]
  field :state

  field :subject
  field :latest_at

  field :lead_ids, type: :array, default: []
  def leads
    Lead.find( lead_ids )
  end

  field :term_ids, type: :array, default: []
  def tags
    WpTag.find( term_ids )
  end

  has_many :email_messages
  def email_messages
    Office::EmailMessage.where( email_conversation_id: self.id )
  end

end
# EmailConversation = Office::EmailConversation
Conv = Office::EmailConversation
