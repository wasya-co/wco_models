
class Wco::Profile
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'ish_user_profiles'

  field :email
  index({ email: 1 }, { name: 'email' })
  validates :email, presence: true, uniqueness: true

  field :per_page, type: :integer, default: 25
  field :show_n_thumbs, type: :integer, default: 8

  belongs_to :leadset,          class_name: 'Wco::Leadset', inverse_of: :profile,         optional: true
  has_many :newsitems, class_name: 'Wco::Newsitem'
  has_and_belongs_to_many :shared_galleries, class_name: 'Wco::Gallery', inverse_of: :shared_profiles


  def to_s
    email
  end
  def self.list
    all.map { |p| [ p.email, p.id ] }
  end
end
