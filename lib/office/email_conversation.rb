
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



  has_many :email_messages
  def email_messages
    Office::EmailMessage.where( email_conversation_id: self.id )
  end

  def tags
    WpTag.find( wp_term_ids )
  end

  ## Copied from email_message
  field :wp_term_ids, type: Array, default: []

  ## Tested manually ok, does not pass the spec. @TODO: hire to make pass spec? _vp_ 2023-03-07
  def add_tag tag
    if WpTag == tag.class
      self[:wp_term_ids] = self[:wp_term_ids].push(tag.id).uniq
      self.save!
    else
      throw "#add_tag expects a WpTag as the only parameter."
    end
  end

  def remove_tag tag
    if WpTag == tag.class
      self[:wp_term_ids].delete( tag.id )
      self.save!
    else
      throw "#remove_tag expects a WpTag as the only parameter."
    end
  end

  def self.in_inbox
    ::Office::EmailConversation.where( :wp_term_ids => WpTag.email_inbox_tag.id ).order_by( latest_at: :desc )
  end

end
# EmailConversation = Office::EmailConversation
Conv = Office::EmailConversation
