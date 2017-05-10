
class Feature  

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,    :type => String
  field :subhead, :type => String

  field :image_path,   :type => String
  field :link_path,    :type => String
  field :partial_name, :type => String
  field :inner_html,   :type => String
  field :weight,       :type => Integer, :default => 10
  
  belongs_to :photo
  belongs_to :report
  belongs_to :gallery
  belongs_to :video
  # has_one :photo
  # has_one :report
  # has_one :gallery
  # has_one :video

  embedded_in :venue
  embedded_in :site
  embedded_in :city
  embedded_in :tag

  def self.all
    self.order_by( :created_at => :desc )
  end

  def self.n_features
    4
  end
  
end
