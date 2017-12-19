
class CoTailors::Address
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :profile, :class_name => '::IshModels::UserProfile'

  field :name
  field :address_1
  field :address_2
  field :city
  field :state
  field :zip
  field :phone

end

