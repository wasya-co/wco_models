
class Wco::Profile
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email

  field :per_page, type: :integer, default: 25

end
