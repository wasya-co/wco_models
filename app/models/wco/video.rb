
require 'mongoid_paperclip'
require 'streamio-ffmpeg'

class Wco::Video
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps
  include Wco::Utils
  store_in collection: 'videos'

  PAGE_PARAM_NAME = 'videos_page'

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

  field :duration_ms, type: :integer

  belongs_to :lead,        optional: true
  belongs_to :newspartial, optional: true
  belongs_to :newsvideo,   optional: true

  has_and_belongs_to_many :tags


  has_mongoid_attached_file :video,
    # styles: { :thumb => { geometry: '192x108', format: 'jpeg' }, },
    # processors: [ :transcoder ],
    :storage => :s3,
    :s3_credentials => ::S3_CREDENTIALS,
    :path => "videos/:style/:id/:filename",
    :s3_protocol => 'https',
    # :s3_permissions => 'public-read',
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

  before_create :set_duration_ms
  def set_duration_ms
    return unless video.queued_for_write[:original]
    path = video.queued_for_write[:original].path
    movie = ::FFMPEG::Movie.new(path)
    self.duration_ms = (movie.duration * 1000).to_i if movie.duration
  end

  before_create :set_title
  def set_title
    return unless video.present?
    filename = video_file_name # Paperclip metadata
    return unless filename
    self.name = File.basename(filename, ".*") if self.name.blank?
  end

  def self.list
    [['', nil]] + self.unscoped.order_by( :created_at => :desc ).map do |item|
      [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ]
    end
  end

  def generate_thumbnail
    return unless video.queued_for_write[:original]

    input_path  = video.queued_for_write[:original].path
    output_path = Rails.root.join('tmp', "thumb_#{SecureRandom.hex}.jpg")
    movie = ::FFMPEG::Movie.new(input_path)
    movie.screenshot(output_path.to_s, seek_time: 1) ## at time 00:00:01 seconds
    self.thumb = File.open(output_path)
    File.delete(output_path) if File.exist?(output_path)
  end

end
