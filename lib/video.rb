require 'mongoid/paranoia'
require_relative './mongoid/votable.rb'

class Video
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Paranoia
  include Ish::Utils

  include Mongoid::Votable
  vote_point self, :up => +1, :down => -1

  PER_PAGE = 6

  field :name, :type => String
  field :descr, :type => String, :as => :description

  field :is_trash, :type => Boolean, :default => false
  def is_trash
    if deleted_at
      true
    else
      self[:is_trash]
    end
  end

  field :is_public, :type => Boolean, :default => false
  field :is_feature, :type => Boolean, :default => false

  field :x, :type => Float
  field :y, :type => Float

  field :lang, :type => String, :default => 'en'

  field :youtube_id, :type => String
  # validates :youtube_id, :uniqueness => true, :presence => true

  has_and_belongs_to_many :tags
  belongs_to :city, :optional => true
  belongs_to :site, :optional => true
  # has_many :newsitems # unnecessary, right? _vp_ 20200412

  belongs_to :user_profile, :optional => true, :class_name => 'Ish::UserProfile', :inverse_of => :videos

  accepts_nested_attributes_for :site, :tags, :city

  def self.list
    [['', nil]] + Video.unscoped.order_by( :created_at => :desc ).map { |item| [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ] }
  end

  set_callback( :create, :before ) do |doc|
    if doc.is_public
      doc.city.add_newsitem( doc ) unless doc.city.blank?
      doc.site.add_newsitem( doc ) unless doc.site.blank?
    end
  end

  field :issue
  field :subhead

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

  set_callback :update, :after do |doc|
    Site.update_all updated_at: Time.now
  end

  ## copy-paste
  field :premium_tier, type: Integer, default: 0 # how many stars need to spend, to get access? 0 = free
  def is_premium
    premium_tier > 0
  end
  def premium?; is_premium; end
  has_many :premium_purchases, class_name: '::Gameui::PremiumPurchase', as: :item

  def export_fields
    %w| name descr |
  end



end
