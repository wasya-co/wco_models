
require 'aws-sdk'
require 'mongoid_paperclip'

class ::Gameui::Asset3d
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Ish::Utils

  belongs_to :marker,       class_name: 'Gameui::Marker', optional: true

  has_mongoid_attached_file :object,
                            :storage => :s3,
                            :s3_credentials => ::S3_CREDENTIALS,
                            :path => "assets3d/:id/:filename",
                            :s3_protocol => 'https',
                            :validate_media_type => false,
                            s3_region: ::S3_CREDENTIALS[:region]

  do_not_validate_attachment_file_type :object

  def export_fields
    %w|
      marker_id
      asset3d_file_name asset3d_content_type asset3d_file_size asset3d_updated_at asset3d_fingerprint
    |;
  end

end
