
##
## When I receive one.
##
class Office::EmailMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :raw,         type: :string
  field :object_key,  type: :string ## aka 'filename', use with bucket name + prefix
  # validates_presence_of :object_key
  field :object_path, type: :string ## A routable s3 url

  field :subject
  field :part_txt
  field :part_html
  # attachments ?

  field :from, type: Array, default: []
  def from_str
    from.join(", ")
  end

  field :to,   type: Array, default: []
  field :cc,   type: Array, default: []
  field :bcc,  type: Array, default: []
  field :date, type: DateTime
  def received_at
    date
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

  ## action.match_from = '@synchrony.com'
  def apply_actions
    triggers = Office::Action.active.where({ channel: 'email' })
    triggers.each do |trigger|
      if self.from_str.match(/#{trigger.match_from}/i)
        trigger.actions do |action|
          Office::Action.call( action[:method], { msg: self }.merge( action[:params] ))
        end
      end
    end
  end

end
