
require 'ish/utils'

class Newsitem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ish::Utils

  belongs_to :site,    :optional => true
  belongs_to :tag,     :optional => true
  belongs_to :city,    :optional => true
  belongs_to :report,  :optional => true
  belongs_to :user_profile, class_name: 'Ish::UserProfile', optional: true
  belongs_to :map, class_name: '::Gameui::Map', optional: true

  belongs_to :gallery, :optional => true
  def gallery
    self.gallery_id ? Gallery.unscoped.find( self.gallery_id ) : nil
  end

  belongs_to :video,   :optional => true

  has_one :photo

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
    %w| name descr image_path link_path |
  end

  def collect export_object
    export_object[:galleries][gallery.id.to_s] = gallery.id.to_s if gallery
    export_object[:photos][photo.id.to_s] = photo.id.to_s if photo
    export_object[:reports][report.id.to_s] = report.id.to_s if report
    export_object[:videos][video.id.to_s] = video.id.to_s if video
  end

end
