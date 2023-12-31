
# require 'aws-sdk'
require 'mongoid_paperclip'

class Wco::Asset
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Wco::Utils

  field :filename

  belongs_to :email_message, class_name: 'WcoEmail::Message', optional: true

  has_mongoid_attached_file :object,
                            :storage => :s3,
                            :s3_credentials => ::S3_CREDENTIALS,
                            :path => "assets/:id/:filename",
                            :s3_protocol => 'https',
                            :validate_media_type => false,
                            s3_region: ::S3_CREDENTIALS[:region]

  do_not_validate_attachment_file_type :object

end
