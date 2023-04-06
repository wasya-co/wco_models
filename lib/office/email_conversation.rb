
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
    case tag.class.name
    when 'WpTag'
      ;
    when 'String'
      tag = WpTag.emailtag(tag)
    else
      throw "#add_tag expects a WpTag or string (eg WpTag::INBOX) as the only parameter."
    end
    self[:wp_term_ids] = ( [ tag.id ] + self[:wp_term_ids] ).uniq
    self.save!
  end

  def remove_tag tag
    case tag.class.name
    when 'WpTag'
      ;
    when 'String'
      tag = WpTag.emailtag(tag)
    else
      throw "#remove_tag expects a WpTag or string (eg WpTag::INBOX) as the only parameter."
    end
    self[:wp_term_ids] = self[:wp_term_ids] - [ tag.id ]
    out = self.save!
    out
  end
  def rmtag tag; remove_tag tag; end

  def self.not_in_emailtag which
    case which.class.name
    when 'String'
      tag_id = WpTag.emailtag(which).id
    when 'WpTag'
      tag_id = which.id
    else
      throw "unsupported in #not_in_emailtag: #{which}"
    end
    return ::Office::EmailConversation.where( :wp_term_ids.ne => tag_id ).order_by( latest_at: :desc )
  end

  def self.in_emailtag which
    case which.class.name
    when 'String'
      tag_id = WpTag.emailtag(which).id
    when 'WpTag'
      tag_id = which.id
    else
      throw "unsupported in #in_emailtag: #{which}"
    end
    return ::Office::EmailConversation.where( :wp_term_ids => tag_id ).order_by( latest_at: :desc )
  end

end
Conv = Office::EmailConversation
