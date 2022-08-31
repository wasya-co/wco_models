
require 'ish/utils'
# require_relative './mongoid/votable.rb'

class Newsitem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ish::Utils

  include Mongoid::Votable
  vote_point self, :up => +1, :down => -1

  belongs_to :city,    optional: true
  belongs_to :gallery, optional: true  # seems correct. _vp_ 2022-03-21
  def gallery
    self.gallery_id ? Gallery.unscoped.find( self.gallery_id ) : nil
  end
  belongs_to :map,     optional: true, class_name: '::Gameui::Map'
  belongs_to :profile, optional: true, class_name: 'Ish::UserProfile'
  belongs_to :photo,   optional: true
  belongs_to :report,  optional: true
  belongs_to :site,    optional: true
  belongs_to :tag,     optional: true
  belongs_to :video,   optional: true

  field :name
  field :descr
  def description
    descr
  end

  field :image_path
  field :link_path
  field :username
  field :partial_name

  field :weight,           :type => Integer, :default => 10
  field :n_upvotes,        :type => Integer, :default => 0
  field :n_downvotes,      :type => Integer, :default => 0
  field :upvoting_users,   :type => Array, :default => []
  field :downvoting_users, :type => Array, :default => []
  field :is_feature,       :type => Boolean, :default => false

  TYPE_GALLERY = :type_gallery
  TYPE_PHOTO   = :type_photo
  TYPE_REPORT  = :type_report
  TYPE_VIDEO   = :type_video
  def item_type
    return TYPE_GALLERY if gallery_id
    return TYPE_PHOTO   if photo_id
    return TYPE_REPORT  if report_id
    return TYPE_VIDEO   if video_id
  end


  PER_PAGE = 6

  default_scope ->{ order_by({ :created_at => :desc }) }

  def self.from_params item
    n = Newsitem.new
    n.descr = item[:descr]
    n.username = item[:username]

    unless item[:report_id].blank?
      n.report = Report.find item[:report_id]
    end

    unless item[:gallery_id].blank?
      n.gallery = Gallery.find item[:gallery_id]
    end

    n.partial_name = item.partial_name unless item.partial_name.blank?

    return n
  end

  def export_fields
    %w|
      descr
      gallery_id
      image_path
      link_path
      map_id
      name
      photo_id
      report_id
      video_id
    |
  end

  def collect export_object
    export_object[:galleries][gallery.id.to_s] = gallery.id.to_s if gallery
    export_object[:photos][photo.id.to_s] = photo.id.to_s if photo
    export_object[:reports][report.id.to_s] = report.id.to_s if report
    export_object[:videos][video.id.to_s] = video.id.to_s if video
  end

end
