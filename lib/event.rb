
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

  field :x, :type => Float
  field :y, :type => Float

  has_one :profile_photo, :class_name => 'Photo', :inverse_of => :profile_event
  has_many :photos

end

