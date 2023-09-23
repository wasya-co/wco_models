
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

  belongs_to :email_conversation
  def conv
    email_conversation
  end

  def preview_str
    body = part_html || part_html || 'Neither part_html nor part_txt!'
    body = ::ActionView::Base.full_sanitizer.sanitize( body ).gsub(/\s+/, ' ')
    body = body[0..200]
    body
  end

end
::Msg = Office::EmailMessage




