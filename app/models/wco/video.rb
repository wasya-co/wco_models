
require 'mongoid_paperclip'

class Wco::Video
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'videos'

  field :name, :type => String
  index({ created_at: -1 })
  index({ created_at: -1, name: -1 })

  field :descr, :type => String, :as => :description
  field :subhead ## still need it... 2023-03-24

  field :is_public, :type => Boolean, :default => false
  def published
    where({ :is_public => true }).order_by({ :created_at => :desc })
  end

  field :x, type: Float
  field :y, type: Float
  field :z, type: Float

  field :youtube_id
  validates_uniqueness_of :youtube_id, allow_blank: true, case_sensitive: false
  before_save { youtube_id.present? || youtube_id = nil }

  # belongs_to :user_profile,                  :class_name => 'Ish::UserProfile', :inverse_of => :videos
  # has_and_belongs_to_many :shared_profiles,  :class_name => 'Ish::UserProfile', :inverse_of => :shared_videos

  has_mongoid_attached_file :video,
    # styles: { :thumb => { geometry: '192x108', format: 'jpeg' }, },
    # processors: [ :transcoder ],
    :storage => :s3,
    :s3_credentials => ::S3_CREDENTIALS,
    :path => "videos/:style/:id/:filename",
    :s3_protocol => 'https',
    :s3_permissions => 'public-read',
    :validate_media_type => false,
    s3_region: ::S3_CREDENTIALS[:region]
  validates_attachment_content_type :video, content_type: /\Avideo\/.*\Z/

  has_mongoid_attached_file :thumb,
    :styles => {
      :mini   => '20x20#',
      :thumb  => "100x100#",
      :thumb2  => "200x200#",
      :s169 => "640x360#",
      # :s43 => "640x480#",
      :small  => "400x400>",
      :large  => '950x650>',
    },
    :storage => :s3,
    :s3_credentials => ::S3_CREDENTIALS,
    :path => "videos/:style/:id/thumb_:filename",
    :s3_protocol => 'https',
    :validate_media_type => false,
    s3_region: ::S3_CREDENTIALS[:region]
  validates_attachment_content_type :thumb, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", 'application/octet-stream' ]

  def export_fields
    %w| name descr |
  end

  def self.list
    [['', nil]] + self.unscoped.order_by( :created_at => :desc ).map do |item|
      [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ]
    end
  end

end
