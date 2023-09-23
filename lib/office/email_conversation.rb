
class Office::EmailConversation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  STATE_UNREAD = 'state_unread'
  STATE_READ   = 'state_read'
  STATES       = [ STATE_UNREAD, STATE_READ ]
  field :state

  field :subject
  field :latest_at
  index({ latest_at: -1 })

  has_many :email_conversation_leads, class_name: 'Office::EmailConversationLead'
  # def lead_ids
  #   email_conversation_leads.map( &:lead_id )
  # end
  field :lead_ids, type: :array, default: []
  def leads
    Lead.find( lead_ids.compact )
  end

  has_many :email_messages
  def email_messages
    Office::EmailMessage.where( email_conversation_id: self.id )
  end

  ##
  ## A `tags` concern
  ##

  has_many :email_conversation_tags, class_name: 'Office::EmailConversationTag'

  def wp_term_ids ## @TODO: remove _vp_ 2023-09-23
    email_conversation_tags.map( &:wp_term_id )
  end

  def tags
    WpTag.find( email_conversation_tags.map( &:wp_term_id ) )
  end

  ## Tested manually ok, does not pass the spec. @TODO: hire to make pass spec? _vp_ 2023-03-07
  def add_tag which
    tag = WpTag.iso_get which
    # puts!( tag.slug, "Adding tag" ) if DEBUG
    Office::EmailConversationTag.find_or_create_by!({
      email_conversation_id: id,
      wp_term_id:            tag.id,
    })
  end

  def remove_tag which
    tag = WpTag.iso_get which
    # puts!( tag.slug, "Removing tag" ) if DEBUG
    Office::EmailConversationTag.where({
      email_conversation_id: id,
      wp_term_id:            tag.id,
    }).first&.delete
  end
  def rmtag which; remove_tag which; end

  def in_emailtag? which
    tag = WpTag.iso_get( which )
    email_conversation_tags.where({ wp_term_id: tag.id }).present?
  end

  def self.in_emailtag which
    tag = WpTag.iso_get( which )
    email_conversation_tags = Office::EmailConversationTag.where({ wp_term_id: tag.id })
    where({ :id.in => email_conversation_tags.map(&:email_conversation_id) })
  end

  def self.not_in_emailtag which
    tag = WpTag.iso_get( which )
    email_conversation_tags = Office::EmailConversationTag.where({ wp_term_id: tag.id })
    where({ :id.nin => email_conversation_tags.map(&:email_conversation_id) })
  end


  def apply_filter filter
    case filter.kind

    when ::Office::EmailFilter::KIND_DESTROY_SCHS
      add_tag    ::WpTag::TRASH
      remove_tag ::WpTag::INBOX
      tmp_lead = ::Lead.where( email: self.part_txt.split("\n")[1] ).first
      if tmp_lead
        tmp_lead.schs.each do |sch|
          sch.update_attributes({ state: ::Sch::STATE_TRASH })
        end
      end

    when ::Office::EmailFilter::KIND_ADD_TAG
      add_tag filter.wp_term_id
      if ::WpTag::TRASH == ::WpTag.find( filter.wp_term_id ).slug
        remove_tag ::WpTag::INBOX
      end

    when ::Office::EmailFilter::KIND_REMOVE_TAG
      remove_tag filter.wp_term_id

    when ::Office::EmailFilter::KIND_AUTORESPOND_TMPL
      Ish::EmailContext.create({
        email_template: filter.email_template,
        lead_id:        lead.id,
        send_at:        Time.now + 22.minutes,
      })

    when ::Office::EmailFilter::KIND_AUTORESPOND_EACT
      ::Sch.create({
        email_action: filter.email_action,
        state:        ::Sch::STATE_ACTIVE,
        lead_id:      lead.id,
        perform_at:   Time.now + 22.minutes,
      })

    else
      raise "unknown filter kind: #{filter.kind}"
    end
  end



end
Conv = Office::EmailConversation
