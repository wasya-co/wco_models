class PublicItem

=begin
  ## let's try to make it work with newsitems, without publicitems yet.

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :site
  belongs_to :city
  belongs_to :tag
  
  field :username

  # acts as a report
  # acts as a gallery
  # acts as a video  
  has_many :photos

  belongs_to :photo
  belongs_to :report
  belongs_to :gallery
  belongs_to :video

  field :name, :type => String
  field :descr, :type => String
  field :image_path, :type => String
  field :link_path, :type => String
  field :username, :type => String # @TODO do I use this???
  field :partial_name, :type => String, :default => nil  # @deprecated, but let's not remove it.

  field :weight, :type => Integer, :default => 10
  field :n_upvotes, :type => Integer, :default => 0
  field :n_downvotes, :type => Integer, :default => 0
  field :upvoting_users, :type => Array, :default => []
  field :downvoting_users, :type => Array, :default => []
  field :is_feature, :type => Boolean, :default => false

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
=end

end
