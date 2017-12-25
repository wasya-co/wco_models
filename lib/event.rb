
class Event
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type => String
  validates :name, :presence => true, :uniqueness => true

  field :eventname, :type => String
  validates :eventname, :presence => true, :uniqueness => true

  field :description, :type => String

  field :date, :type => DateTime
  validates :date, :presence => true
  
  belongs_to :city
  validates :city, :presence => true
  
end

