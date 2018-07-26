class Newsitem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :site,    :optional => true
  belongs_to :tag,     :optional => true
  belongs_to :city,    :optional => true
  belongs_to :report,  :optional => true
  
  belongs_to :gallery, :optional => true
  def gallery
    self.gallery_id ? Gallery.unscoped.find( self.gallery_id ) : nil
  end

  belongs_to :video,   :optional => true

  has_one :photo

  field :name
  field :descr
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
  
end
