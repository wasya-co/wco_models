
class Office::EmailConversation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

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

  # @deprecated, @TODO: remove
  has_many :lead_ties,     class_name: 'Office::EmailConversationLead'
  has_many :wco_lead_ties, class_name: '::Wco::EmailConversationLead'


  def leads
    Lead.find( lead_ties.map( &:lead_id ) )
  end

  has_many :email_messages,          class_name: 'Office::EmailMessage'
  has_many :email_conversation_tags, class_name: 'Office::EmailConversationTag'
  has_many :emailtag_ties,           class_name: 'Office::EmailtagEmailConversation'

  def tags
    Emailtag.find( emailtag_ties.map &:emailtag_id )
  end

  # ## Tested manually ok, does not pass the spec. @TODO: hire to make pass spec? _vp_ 2023-03-07
  # def add_tag which
  #   tag = WpTag.iso_get which
  #   # puts!( tag.slug, "Adding tag" ) if DEBUG
  #   Office::EmailConversationTag.find_or_create_by!({
  #     email_conversation_id: id,
  #     wp_term_id:            tag.id,
  #   })
  # end
  def add_tag which
    ::EmailtagTie.create!({ emailtag: which, email_conversation: self })
  end

  # def remove_tag which
  #   tag = WpTag.iso_get which
  #   # puts!( tag.slug, "Removing tag" ) if DEBUG
  #   Office::EmailConversationTag.where({
  #     email_conversation_id: id,
  #     wp_term_id:            tag.id,
  #   }).first&.delete
  # end
  def remove_tag which
    ::EmailtagTie.find_by({ emailtag: which, email_conversation: self }).delete
  end
  def rmtag which; remove_tag which; end

  # def in_emailtag? which
  #   tag = WpTag.iso_get( which )
  #   email_conversation_tags.where({ wp_term_id: tag.id }).present?
  # end
  def in_emailtag? which
    if which.class == String
      which = Office::Emailtag.find_by({ slug: which })
    end
    !!::EmailtagTie.where({ emailtag: which, email_conversation: self }).first
  end

  # def self.in_emailtag which
  #   tag = WpTag.iso_get( which )
  #   email_conversation_tags = Office::EmailConversationTag.where({ wp_term_id: tag.id })
  #   where({ :id.in => email_conversation_tags.map(&:email_conversation_id) })
  # end
  def self.in_emailtag which, page: 1, per: 25
    conv_ids = ::EmailtagTie.find_by({ emailtag: which }).map( &:email_conversation_id )
    Conv.where({ id: conv_ids }).order_by({ updated_at: :desc }).page( page ).per( per )
  end

  # def self.not_in_emailtag which
  #   tag = WpTag.iso_get( which )
  #   email_conversation_tags = Office::EmailConversationTag.where({ wp_term_id: tag.id })
  #   where({ :id.nin => email_conversation_tags.map(&:email_conversation_id) })
  # end
  def self.not_in_emailtag which, page: 1, per: 25
    conv_ids = ::EmailtagTie.find_by({ emailtag: which }).map( &:email_conversation_id )
    Conv.where({ :id.nin => conv_ids }).order_by({ updated_at: :desc }).page( page ).per( per )
  end





end
Conv = Office::EmailConversation
