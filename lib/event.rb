
class Event
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type => String
  validates :name, :presence => true, :uniqueness => true

  field :name_seo, :type => String
  validates :name_seo, :presence => true, :uniqueness => true

  field :descr, :type => String

  field :date, :type => DateTime
  validates :date, :presence => true
  
  belongs_to :city
  validates :city, :presence => true
  
end
