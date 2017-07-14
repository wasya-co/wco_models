
class UserProfile
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username

  has_many :videos

end
