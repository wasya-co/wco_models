class Photo
  require 'aws-sdk'

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  belongs_to :user,     :inverse_of => :photos
  validates  :user,     :presence => true
  field      :username, :type => String

  has_and_belongs_to_many :viewers, :class_name => 'User', :inverse_of => :viewable_photos
  
  belongs_to :profile_user, :class_name => 'User', :inverse_of => :profile_photo
  belongs_to :profile_city, :class_name => 'City', :inverse_of => :profile_photo
  belongs_to :profile_venue, :class_name => 'Venue', :inverse_of => :profile_photo
  
  belongs_to :report
  belongs_to :tag
  belongs_to :venue
  belongs_to :feature
  belongs_to :gallery
  
  field :name,   :type => String
  field :descr,  :type => String
  field :weight, :type => Integer, :default => 10
  
  field :is_public, :type => Boolean, :default => true

  # @TODO: nuke this boolean _vp_ 20170515
  field :is_trash,  :type => Boolean, :default => false
  default_scope ->{ where({ :is_trash => false }) }

  has_mongoid_attached_file :photo, 
                            :styles => {
                              :mini => '20x20#',
                              :thumb => "100x100#",
                              :small  => "400x400>",
                              :large => '950x650>'
                            },
                            :storage => :s3,
                            :s3_credentials => ::IshModels.configuration.s3_credentials,
                            :bucket => ::IshModels.configuration.s3_credentials[:bucket],
                            :path => "photos/:style/:id/:filename"
  
  def self.n_per_manager_gallery
    25
  end

  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  
end


