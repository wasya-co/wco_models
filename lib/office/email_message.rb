
require 'action_view'

##
## When I receive one.
##
class Office::EmailMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :raw,         type: :string

  field :message_id,  type: :string # MESSAGE-ID
  validates_uniqueness_of :message_id
  index({ message_id: 1 }, { unique: true, name: "id_idx" })

  field :in_reply_to_id, type: :string

  field :object_key,  type: :string ## aka 'filename', use with bucket name + prefix. I need this!
  # validates_presence_of :object_key
  field :object_path, type: :string ## A routable s3 url

  field :subject
  field :part_txt
  field :part_html
  field :preamble
  field :epilogue

  has_many :attachments, class_name: 'Photo'

  def lead
    Lead.find_by email: from
  end

  field :from,   type: :string
  field :froms,  type: Array, default: []
  field :to,     type: :string
  field :tos,    type: Array, default: []
  field :cc,     type: :string
  field :ccs,    type: Array, default: []
  field :bcc,    type: :string
  field :bccs,   type: Array, default: []

  field :date, type: DateTime
  def received_at
    date
  end

  belongs_to :email_conversation, class_name: 'Office::EmailConversation'
  def conv
    email_conversation
  end

  has_many :email_attachments, class_name: 'Office::EmailAttachment', inverse_of: :email_message

  def preview_str
    body = part_html || part_html || 'Neither part_html nor part_txt!'
    body = ::ActionView::Base.full_sanitizer.sanitize( body ).gsub(/\s+/, ' ')
    body = body[0..200]
    body
  end


  def apply_filter filter
    case filter.kind

    when ::Office::EmailFilter::KIND_DESTROY_SCHS
      conv.add_tag    ::WpTag::TRASH
      conv.remove_tag ::WpTag::INBOX
      lead.schs.each do |sch|
        sch.update_attributes({ state: ::Sch::STATE_TRASH })
      end

    when ::Office::EmailFilter::KIND_ADD_TAG
      conv.add_tag filter.wp_term_id
      if ::WpTag::TRASH == ::WpTag.find( filter.wp_term_id ).slug
        conv.remove_tag ::WpTag::INBOX
      end

    when ::Office::EmailFilter::KIND_REMOVE_TAG
      conv.remove_tag filter.wp_term_id

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
::Msg = Office::EmailMessage




