require 'mongoid/paranoia'
require 'mongoid_paperclip'
require_relative './mongoid/votable.rb'

class Video
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Paranoia
  include Ish::PremiumItem
  include Ish::Utils

  include Mongoid::Votable
  vote_point self, :up => +1, :down => -1

  PER_PAGE = 6

  field :name, :type => String
  field :descr, :type => String, :as => :description
  field :subhead ## still need it... 2023-03-24

  field :is_trash, :type => Boolean, :default => false
  def is_trash
    if deleted_at
      true
    else
      self[:is_trash]
    end
  end

  field :is_public, :type => Boolean, :default => false

  field :x, type: Float
  field :y, type: Float
  field :z, type: Float

  field :youtube_id
  validates_uniqueness_of :youtube_id, allow_blank: true, case_sensitive: false
  before_save { youtube_id.present? || youtube_id = nil }

  belongs_to :user_profile, :optional => true, :class_name => 'Ish::UserProfile', :inverse_of => :videos

  index({ is_trash: 1, user_profile_id: 1, created_at: 1 }, { name: 'idx1' })

  def self.list
    [['', nil]] + Video.unscoped.order_by( :created_at => :desc ).map { |item| [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ] }
  end

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

end
