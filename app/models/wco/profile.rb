
class Wco::Profile
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'ish_user_profiles'

  field :email
  index({ email: 1 }, { name: 'email' })
  validates :email, presence: true, uniqueness: true

  field :per_page, type: :integer, default: 25

  belongs_to :leadset, class_name: 'Wco::Leadset', inverse_of: :profile, optional: true

  def self.list
    all.map { |p| [ p.email, p.id ] }
  end

end
