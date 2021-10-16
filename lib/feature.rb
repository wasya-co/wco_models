
class Feature
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :subhead

  field :image_path
  field :link_path
  field :partial_name
  field :inner_html
  field :weight, type: Integer, default: 10

  belongs_to :city, optional: true
  belongs_to :gallery, optional: true
  belongs_to :photo, optional: true
  belongs_to :report, optional: true
  belongs_to :site, optional: true
  belongs_to :tag, optional: true
  belongs_to :video, optional: true
  belongs_to :venue, optional: true

  def self.all
    self.order_by( :created_at => :desc )
  end

  def self.n_features
    4
  end

end
