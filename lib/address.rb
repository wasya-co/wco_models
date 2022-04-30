
class Address
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :profile, :class_name => '::Ish::UserProfile'
  validates :profile, :presence => true

  field :name
  field :address_1
  field :address_2
  field :city
  field :state
  field :zipcode
  field :phone

end

