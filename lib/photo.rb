
# require 'aws-sdk'
require 'mongoid_paperclip'

class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Ish::Utils

  belongs_to :user_profile,  :class_name => 'Ish::UserProfile',               :optional => true
  def user
    user_profile
  end
  belongs_to :user_profile,  :class_name => 'Ish::UserProfile',  :inverse_of => :profile_photo, :optional => true

  belongs_to :report,   :optional => true
  belongs_to :gallery,  :optional => true
  belongs_to :newsitem, :optional => true

  # photo.photo.to_s.split('/').last.split('?').first
  field :name,   :type => String
  def name
    return self[:name] if self[:name]
    update_attribute(:name, self.photo.to_s.split('/').last.split('?').first)
    name
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

  validates_attachment_content_type :photo, :content_type => ["image/webp", "image/jpg", "image/jpeg", "image/png", "image/gif", 'application/octet-stream' ]

end


