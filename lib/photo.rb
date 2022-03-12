
require 'aws-sdk'

class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Ish::Utils

  has_and_belongs_to_many :viewers, :class_name => 'User', :inverse_of => :viewable_photos

  belongs_to :user_profile,  :class_name => 'Ish::UserProfile',               :optional => true
  def user
    user_profile
  end
  belongs_to :profile_city,  :class_name => 'City',                    :inverse_of => :profile_photo, :optional => true
  belongs_to :user_profile,  :class_name => 'Ish::UserProfile',  :inverse_of => :profile_photo, :optional => true
  belongs_to :profile_venue, :class_name => 'Venue',                   :inverse_of => :profile_photo, :optional => true
  belongs_to :profile_event, :class_name => 'Event',                   :inverse_of => :profile_photo, :optional => true

  belongs_to :report,   :optional => true
  belongs_to :venue,    :optional => true
  belongs_to :event,    :optional => true
  belongs_to :feature,  :optional => true
  belongs_to :gallery,  :optional => true
  belongs_to :newsitem, :optional => true

  field :name,   :type => String
  field :descr,  :type => String
  field :weight, :type => Integer, :default => 10

  field :is_public, :type => Boolean, :default => true
  field :is_trash,  :type => Boolean, :default => false # @TODO: nuke this boolean _vp_ 20170515
  default_scope ->{ where({ :is_trash => false }) } # @TODO: nuke default scopes

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

  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", 'application/octet-stream' ]

end


