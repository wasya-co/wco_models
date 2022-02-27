
class Ish::ImageAsset
  require 'aws-sdk'

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  belongs_to :location,     class_name: 'Gameui::Map', inverse_of: :image,       optional: true
  belongs_to :marker,       class_name: 'Gameui::Marker', inverse_of: :image,       optional: true
  belongs_to :marker_title, class_name: 'Gameui::Marker', inverse_of: :title_image, optional: true

  has_mongoid_attached_file :image,
                            :styles => {
                              :thumb  => "100x100#",
                            },
                            :storage => :s3,
                            :s3_credentials => ::S3_CREDENTIALS,
                            :path => "image_assets/:style/:id/:filename",
                            :s3_protocol => 'https',
                            :validate_media_type => false,
                            s3_region: ::S3_CREDENTIALS[:region]

  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", 'application/octet-stream' ]

end

Asset = Ish::ImageAsset
