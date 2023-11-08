
class Office::EmailAttachment
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :email_message, class_name: 'Office::EmailMessage', inverse_of: :email_attachments

  field :content
  field :content_type
  field :filename

end
