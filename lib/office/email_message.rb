
##
## When I receive one.
##
class Office::EmailMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :raw,         type: :string
  field :object_key,  type: :string
  field :object_path, type: :string # raw on s3

  field :subject
  field :part_txt
  field :part_html
  # attachments ?

  field :from, type: Array, default: []
  field :to,   type: Array, default: []
  field :cc,   type: Array, default: []
  field :bss,  type: Array, default: []
  field :date, type: DateTime
  def received_at
    date
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

end
