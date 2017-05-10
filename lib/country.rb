

class Country
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type => String
  field :countryname, :type => String
  
  has_many :cities
  
end