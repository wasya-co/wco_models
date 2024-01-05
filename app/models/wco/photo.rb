
# require 'aws-sdk'
require 'mongoid_paperclip'

class Wco::Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'wco_photos'

  belongs_to :email_message, class_name: 'WcoEmail::Message', optional: true
  belongs_to :gallery,       class_name: 'Wco::Gallery',      optional: true
  belongs_to :lead,          class_name: 'Wco::Lead',         optional: true
  # belongs_to :newsitem,      :optional => true

  field :name
  def name
    if !self[:name]
      update_attribute(:name, self.photo.to_s.split('/').last.split('?').first)
    end
    self[:name]
  end

  field :ordering, type: :integer
  index({ ordering: -1 })

  field :descr,  :type => String
  field :subhead
  field :weight, :type => Integer, :default => 10

  field :is_public, :type => Boolean, :default => true
  field :is_trash,  :type => Boolean, :default => false # @TODO: nuke this boolean _vp_ 20170515
  default_scope ->{ where({ :is_trash => false }) }

  has_mongoid_attached_file :photo,
                            :styles => {
                              :mini   => '20x20#',
                              :thumb  => "100x100#",
                              :thumb2  => "200x200#",
                              :s169 => "640x360#",
                              :small  => "400x400>",
                              :large  => '950x650>',
                            },
                            :storage => :s3,
                            :s3_credentials => ::S3_CREDENTIALS,
                            :path => "photos/:style/:id/:filename",
                            :s3_protocol => 'https',
                            :validate_media_type => false,
                            s3_region: ::S3_CREDENTIALS[:region]
  validates_attachment_content_type :photo, :content_type => ["image/webp", "image/jpg", "image/jpeg", "image/png", "image/gif", 'application/octet-stream' ]

  def self.n_per_manager_gallery
    25
  end

  def export_fields
    %w|
      gallery_id
      name descr weight is_public is_trash

      photo_file_name photo_content_type photo_file_size photo_updated_at photo_fingerprint
    |
  end

  ## From: https://gist.github.com/WizardOfOgz/1012107?permalink_comment_id=1442486
  attr_accessor :content_type, :image_data, :original_filename
  def decode_base64_image
    if image_data && content_type && original_filename
      decoded_data = Base64.decode64(image_data)

      data = StringIO.new(decoded_data)
      data.class_eval do
        attr_accessor :content_type, :original_filename
      end

      data.content_type = content_type
      data.original_filename = File.basename(original_filename)

      self.photo = data
    end
  end

end


