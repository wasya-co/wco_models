
class WcoEmail::Conversation
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Paranoia

  store_in collection: 'office_email_conversations'

  STATE_UNREAD = 'state_unread'
  STATE_READ   = 'state_read'
  STATES       = [ STATE_UNREAD, STATE_READ ]
  field :state

  field :subject
  index({ subject: -1 })

  field :latest_at
  index({ latest_at: -1 })

  field :from_emails, type: :array, default: []
  index({ from_emails: -1 })

  field :preview, default: ''

  # has_many :lead_ties, class_name: 'Office::EmailConversationLead'
  # def lead_ids
  #   email_conversation_leads.map( &:lead_id )
  # end
  # field :lead_ids, type: :array, default: []
  # def leads
  #   Lead.find( lead_ties.map( &:lead_id ) )
  # end

  # has_many :email_messages,          class_name: 'Office::EmailMessage'
  # has_many :email_conversation_tags, class_name: 'Office::EmailConversationTag'

  has_and_belongs_to_many :tags, class_name: 'Wco::Tag'

  # def self.in_tag tag
  #   case tag.class
  #   when String
  #     tag = Wco::Tag.find_by slug: tag
  #   end
  #   where( :tag_ids => tag.id )
  # end

end
Conv = WcoEmail::Conversation
