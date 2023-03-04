
##
## When I receive one.
##
class Office::EmailMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :raw,         type: :string

  field :message_id,  type: :string # MESSAGE-ID
  validates_uniqueness_of :message_id

  field :in_reply_to_id, type: :string

  field :object_key,  type: :string ## aka 'filename', use with bucket name + prefix
  # validates_presence_of :object_key
  field :object_path, type: :string ## A routable s3 url

  field :subject
  field :part_txt
  field :part_html
  # attachments ?

  field :from,  type: :string
  field :froms, type: Array, default: []

  def lead
    Lead.find_by email: from
  end

  field :to,    type: :string
  field :tos,   type: Array, default: []

  field :ccs,   type: Array, default: []

  field :bccs,  type: Array, default: []

  field :date, type: DateTime
  def received_at
    date
  end

  belongs_to :email_conversation
  def conv
    email_conversation
  end

  ## @TODO: reimplement, look at footer instead.
  def name
    return 'associate'
    # from[0].split('@')[0].upcase
  end

  def company_url
    from[0].split('@')[1]
  end

  def process
    Aws.config[:credentials] = Aws::Credentials.new(
      ::S3_CREDENTIALS[:access_key_id],
      ::S3_CREDENTIALS[:secret_access_key]
    )
    s3 = Aws::S3::Client.new

    obj = s3.get_object({
      bucket: 'ish-ses',
      key: self.object_key
    })
    obj2 = obj.body.read

    mail        = Mail.read_from_string( obj2 )
    self.from    = mail.from
    self.to      = mail.to
    self.subject = mail.subject
    self.date    = mail.date
    self.raw     = obj2

    self.save
  end

  def apply_filter filter

    case filter.kind
    when 'skip-inbox'
      self.tags.delete( WpTag.email_inbox_tag )
    when 'autorespond'
      Ish::EmailContext.create({
        email_template: Tmpl.find_by_slug( filter.email_template_slug ),
        lead: lead,
      })
    when 'autorespond-remind'
      Office::EmailAction.create({
        tmpl_slug: 'require-sign-nda',
        next_in_days: -> { rand(1..5) },
        next_at_time: ->{ rand(8..16).hours + rand(1..59).minutes },
        next_action: 're-remind-sign-nda',
      })

      Ish::EmailContext.create({
        email_template: Tmpl.find_by_slug( filter.email_template_slug ),
        lead: lead,
      })
    else
      raise "unknown filter kind: #{filter.kind}"
    end

  end

end
Msg = Office::EmailMessage


