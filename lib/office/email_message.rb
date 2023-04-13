
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

  field :object_key,  type: :string ## aka 'filename', use with bucket name + prefix
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
  field :ccs,    type: Array, default: []
  field :bccs,   type: Array, default: []

  field :date, type: DateTime
  def received_at
    date
  end

  ## Copied to email_conversation
  field :wp_term_ids, type: Array, default: []

  ## Tested manually ok, does not pass the spec. @TODO: hire to make pass spec? _vp_ 2023-03-07
  def add_tag tag
    case tag.class.name
    when 'WpTag'
      ;
    when 'String'
      tag = WpTag.emailtag(tag)
    else
      throw "#add_tag2 expects a WpTag or string (eg WpTag::INBOX) as the only parameter."
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
      throw "#remove_tag2 expects a WpTag or string (eg WpTag::INBOX) as the only parameter."
    end
    self[:wp_term_ids] = self[:wp_term_ids] - [ tag.id ]
    out = self.save!
    out
  end
  def rmtag tag; remove_tag tag; end

  belongs_to :email_conversation
  def conv
    email_conversation
  end

  ## @TODO: reimplement
  def name
    return 'associate'
    # from[0].split('@')[0].upcase
  end

  def company_url
    from[0].split('@')[1]
  end

  ## @TODO: move to email_conversation _vp_ 2023-03-24
  def apply_filter filter
    case filter.kind
    when ::Office::EmailFilter::KIND_SKIP_INBOX
      # self.remove_tag( WpTag::INBOX )
      self.conv.remove_tag( WpTag::INBOX )
    when ::Office::EmailFilter::KIND_AUTORESPOND
      Ish::EmailContext.create({
        email_template: ::Tmpl.find_by_slug( filter.email_template_slug ),
        lead: lead,
      })
    else
      raise "unknown filter kind: #{filter.kind}"
    end
  end

  def preview_str
    body = part_html || part_html || 'Neither part_html nor part_txt!'
    body = ::ActionView::Base.full_sanitizer.sanitize( body ).gsub(/\s+/, ' ')
    body = body[0..200]
    body
  end

end
::Msg = Office::EmailMessage
