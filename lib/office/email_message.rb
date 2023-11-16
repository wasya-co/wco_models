
require 'action_view'

##
## When I receive one.
##
class Office::EmailMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :raw,         type: :string
  def the_mail
    Mail.new( raw )
  end

  field :message_id,  type: :string # MESSAGE-ID
  validates_uniqueness_of :message_id
  index({ message_id: 1 }, { unique: true, name: "id_idx" })

  field :in_reply_to_id, type: :string

  field :object_key,  type: :string ## aka 'filename', use with bucket name + prefix. I need this!
  # validates_presence_of :object_key
  field :object_path, type: :string ## A routable s3 url

  field :subject
  field :part_html
  field :part_txt

  def lead
    Lead.find_by email: from
  end

  field :from,   type: :string
  field :froms,  type: Array, default: []
  field :to,     type: :string
  field :tos,    type: Array, default: []
  field :cc,     type: :string
  field :ccs,    type: Array, default: []
  def all_ccs; (tos||[]) + (ccs||[]) + (froms||[]); end
  field :bcc,    type: :string
  field :bccs,   type: Array, default: []

  field :logs, type: Array, default: []

  field :date, type: DateTime
  def received_at
    date
  end

  belongs_to :email_conversation, class_name: 'Office::EmailConversation'
  def conv
    email_conversation
  end

  has_many :email_attachments, class_name: 'Office::EmailAttachment', inverse_of: :email_message
  has_many :attachments,       class_name: 'Photo'



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

  ## From: https://stackoverflow.com/questions/24672834/how-do-i-remove-emoji-from-string/24673322
  def self.strip_emoji(text)
    text = text.force_encoding('utf-8').encode
    clean = ""

    # symbols & pics
    regex = /[\u{1f300}-\u{1f5ff}]/
    clean = text.gsub regex, ""

    # enclosed chars
    regex = /[\u{2500}-\u{2BEF}]/ # I changed this to exclude chinese char
    clean = clean.gsub regex, ""

    # emoticons
    regex = /[\u{1f600}-\u{1f64f}]/
    clean = clean.gsub regex, ""

    #dingbats
    regex = /[\u{2702}-\u{27b0}]/
    clean = clean.gsub regex, ""
  end

  ## For recursive parts of type `related`.
  ## Content dispositions:
  # "inline; creation-date=\"Tue, 11 Apr 2023 19:39:42 GMT\"; filename=image005.png; modification-date=\"Tue, 11 Apr 2023 19:47:53 GMT\"; size=14916",
  #
  ## Content Types:
  # "application/pdf; name=\"Securities Forward Agreement -- HaulHub Inc -- Victor Pudeyev -- 2021-10-26.docx.pdf\""
  # "image/jpeg; name=TX_DL_2.jpg"
  # "image/png; name=image005.png"
  # "multipart/alternative; boundary=_000_BL0PR10MB2913C560ADE059F0AB3A6D11829A9BL0PR10MB2913namp_",
  # "text/html; charset=utf-8"
  # "text/plain; charset=UTF-8"
  # "text/calendar; charset=utf-8; method=REQUEST"
  def churn_subpart part
    if part.content_disposition&.include?('attachment')
      ## @TODO: attachments !
      ;
    else
      if part.content_type.include?("multipart/related") ||
        part.content_type.include?("multipart/alternative")

        part.parts.each do |subpart|
          churn_subpart( subpart )
        end
      else
        # attachment = Office::EmailAttachment.new({
        #   content:       part.decoded,
        #   content_type:  part.content_type,
        #   email_message: self,
        # })
        # attachment.save

        if part.content_type.include?('text/html')
          part_html = part.decoded

        elsif part.content_type.include?("text/plain")
          part_txt = part.decoded

        elsif part.content_type.include?("text/calendar")
          ;
        elsif part.content_type.include?("application/pdf")
          ;
        elsif part.content_type.include?("image/jpeg")
          ;
        elsif part.content_type.include?("image/png")
          ;

        else
          puts! part.content_type, '444 No action for a part with this content_type'

        end
      end
    end
  end


  def body_sanitized
    ActionView::Base.full_sanitizer.sanitize( part_html||'' ).squish
  end
  def preview_str
    body.sanitized[0..200]
  end


end
::Msg = Office::EmailMessage




