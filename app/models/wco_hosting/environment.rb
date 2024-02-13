
class WcoHosting::Environment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_environments'

  belongs_to :leadset,      class_name: 'Wco::Leadset', inverse_of: :environments

  field :name
  validates :name, presence: true, uniqueness: true
  index({ name: -1 }, { unique: true })

  has_many :appliances, class_name: 'WcoHosting::Appliance', inverse_of: :environments

  def to_s
    name
  end
end


